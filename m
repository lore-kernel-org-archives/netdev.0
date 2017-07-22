From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: ti: cpts: convert to use
 kthread_worker
Date: Sat, 22 Jul 2017 07:29:14 +0200
Message-ID: <20170722052914.yo62jqdqsdv4hc5q@localhost.localdomain>
References: <20170721234943.3841-1-grygorii.strashko@ti.com>
 <20170721234943.3841-2-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170721234943.3841-2-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2017 at 06:49:42PM -0500, Grygorii Strashko wrote:
> There could be significant delay in CPTS work schedule under high system
> load and on -RT which could cause CPTS misbehavior due to internal counter
> overflow. Usage of own kthread_worker allows to avoid such kind of issues
> and makes it possible to tune priority of CPTS kthread_worker thread on -RT
> (thread name "cpts").

I have also seen excessive delays in the time stamp work from the
dp83640 under certain loads.  Can we please implement this time stamp
kthread_worker in the PHC subsystem?  That way, the facility can be
used by other drivers without code duplication.

Thanks,
Richard
