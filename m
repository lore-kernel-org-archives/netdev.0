From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/6] net: ethernet: ti: cpts: add support of cpts
 HW_TS_PUSH
Date: Sun, 4 Dec 2016 00:21:30 +0100
Message-ID: <20161203232130.GA17944@netboy>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-4-grygorii.strashko@ti.com>
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
In-Reply-To: <20161128230428.6872-4-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 05:04:25PM -0600, Grygorii Strashko wrote:
> This also change overflow polling period when HW_TS_PUSH feature is
> enabled - overflow check work will be scheduled more often (every
> 200ms) for proper HW_TS_PUSH events reporting.

For proper reporting, you should make use of the interrupt.  The small
fifo (16 iirc) could very well overflow in 200 ms.  The interrupt
handler should read out the entire fifo at each interrupt.

Thanks,
Richard
