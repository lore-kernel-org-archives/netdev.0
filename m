From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v8 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Mon, 10 Oct 2016 07:50:07 -0500
Message-ID: <20161010125007.GA24902@rob-hp-laptop>
References: <1475667578-20799-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1475667578-20799-1-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 05, 2016 at 05:09:38PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> 
> Edge-rate:
> As system and networking speeds increase, a signal's output transition,
> also know as the edge rate or slew rate (V/ns), takes on greater importance
> because high-speed signals come with a price. That price is an assortment of
> interference problems like ringing on the line, signal overshoot and
> undershoot, extended signal settling times, crosstalk noise, transmission
> line reflections, false signal detection by the receiving device and
> electromagnetic interference (EMI) -- all of which can negate the potential
> gains designers are seeking when they try to increase system speeds through
> the use of higher performance logic devices. The fact is, faster signaling
> edge rates can cause a higher level of electrical noise or other type of
> interference that can actually lead to slower line speeds and lower maximum
> system frequencies. This parameter allow the board designers to change the
> driving strange, and thereby change the EMI behavioral.
> 
> Edge-rate parameters (vddmac, edge-slowdown) get from Device Tree.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> 
> ---
> All the review comments updated and resending for review.
> 
> Change set:
> v1:
> - Initial version of Edge-rate driver add by using IOCTL.
> v2:
> - Changed edge-rate parameter to Device Tree with magic number.
> v3:
> - Added Device Tree documentati0n and edge-rate parameter table.
>   Added probe function initialize the vsc8531 private data structure.
> v4:
> - As per review comment, Device Tree parameters (vddmac, edge-slowdown)
>   added.
> v5:
> - As per review comment, Device Tree Document parameters (vddmac, 
>   edge-slowdown) real numbers added. Table number changed from 5 to 1.
> v6:
> - As per review comment, Removed Device Tree header file. Removed MACROs
>   and add ARRAYSIZE
> v7:
> - As per review comment, Removed '-'s (minus) sign in Edge rate table. 
> v8:
> - As per review comment, Added DT vddmac, slowdown value error check. 
> 
> ---
> 
>  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 22 +++----

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

>  drivers/net/phy/mscc.c                             | 69 +++++++++++++++-------
>  include/dt-bindings/net/mscc-phy-vsc8531.h         | 21 -------
>  3 files changed, 59 insertions(+), 53 deletions(-)
>  delete mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
