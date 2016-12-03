From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 00/13] net: ethernet: ti: cpts: update and fixes
Date: Sat, 3 Dec 2016 10:22:11 +0100
Message-ID: <20161203092211.GA2762@netboy>
References: <20161202203023.25526-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161202203023.25526-1-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 02, 2016 at 02:30:10PM -0600, Grygorii Strashko wrote:
> It is preparation series intended to clean up and optimize TI CPTS driver to
> facilitate further integration with other TI's SoCs like Keystone 2.
> 
> Changes in v3:
> - patches reordered: fixes and small updates moved first
> - added comments in code about cpts->cc_mult
> - conversation range (maxsec) limited to 10sec

On net-next:

$ git am ~/grygorii.strashko
Applying: net: ethernet: ti: cpts: switch to readl/writel_relaxed()
Applying: net: ethernet: ti: allow cpts to be built separately
error: patch failed: drivers/net/ethernet/ti/cpsw.c:1963
error: drivers/net/ethernet/ti/cpsw.c: patch does not apply
Patch failed at 0002 net: ethernet: ti: allow cpts to be built separately

Also, you have the order of the SOB tags wrong.  The author's SOB goes
first.

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
