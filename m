From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/6] net: ethernet: ti: netcp: add support of cpts
Date: Mon, 5 Dec 2016 20:30:53 +0100
Message-ID: <20161205193053.GA11980@netboy>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-2-grygorii.strashko@ti.com>
 <20161205144918.oj4jpj65aha3x5gf@rob-hp-laptop>
 <7a484f9c-a47d-3ccd-9611-d00b86feabdd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7a484f9c-a47d-3ccd-9611-d00b86feabdd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2016 at 12:25:57PM -0600, Grygorii Strashko wrote:
> >> --- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
> >> +++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
> >> @@ -113,6 +113,15 @@ Optional properties:
> >>  				will only initialize these ports and attach PHY
> >>  				driver to them if needed.
> >>  
> >> + Properties related to cpts configurations.
> >> +	- cpts_clock_mult/cpts_clock_shift:
> > 
> > Needs vendor prefix. Don't use '_'.
>
> This module is used as part of OMAP and Keystone SoCs, so names for
> this props is ABI already :(

Your automatic calculation makes these unnecessary, and so you can
drop these altogether.

Also, maybe you should mark them as deprecated in cpsw.txt?

(The underscores were my fault, sorry)

Thanks,
Richard
