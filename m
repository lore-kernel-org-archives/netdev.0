From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/6] net: ethernet: ti: cpts: add support of cpts
 HW_TS_PUSH
Date: Fri, 9 Dec 2016 09:50:37 +0100
Message-ID: <20161209085037.GA16009@localhost.localdomain>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-4-grygorii.strashko@ti.com>
 <20161203232130.GA17944@netboy>
 <58eea45f-b8fe-6892-e784-b41638c62fd8@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <58eea45f-b8fe-6892-e784-b41638c62fd8@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 08, 2016 at 01:04:11PM -0600, Grygorii Strashko wrote:
> huh. Seems this is not really good idea, because MISC Irq will be 
> triggered for *any* CPTS event and there is no way to enable it just for
> HW_TS_PUSH.

So what?  That is not a problem.

> So, this doesn't work will with current code for RX/TX timestamping
> (which uses polling mode).

Why doesn't it work?

> + runtime overhead in net RX/TX caused by 
> triggering more interrupts. 

This is not relevant.  Without HW_TS_PUSH, there is no need for
enabling the interrupt simply because we don't need it.  Now, with
HW_TS_PUSH, we do need it.
 
> May be, overflow check/polling timeout can be made configurable (module parameter). 

No, it should just work without any user space fiddling.

I getting a bit tired of your half-baked implementations of the
ancillary clock functions.  Either do it right, or just leave it
unsupported.

Thanks,
Richard
