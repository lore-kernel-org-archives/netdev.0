From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/4] net: phy: Broadcom Cygnus internal Etherent PHY driver
Date: Wed, 30 Sep 2015 14:37:55 -0700
Message-ID: <560C5633.5080203@gmail.com>
References: <1443645163-2822-1-git-send-email-arunp@broadcom.com> <1443645163-2822-5-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443645163-2822-5-git-send-email-arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 30/09/15 13:32, Arun Parameswaran wrote:
> Add support for the Broadcom Cygnus SoCs internal PHY's.
> The PHYs are 1000M/100M/10M capable with support for 'EEE'
> and 'APD' (Auto Power Down).
> 
> This driver supports the following Broadcom Cygnus SoCs:
>  - BCM583XX (BCM58300, BCM58302, BCM58303, BCM58305)
>  - BCM113XX (BCM11300, BCM11320, BCM11350, BCM11360)
> 
> The PHY's on these SoC's require some workarounds for
> stable operation, both during configuration time and
> during suspend/resume. This driver handles the
> application of the workarounds.
> 
> Signed-off-by: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Some suggestions if you need to respin this patch series below, sorry
for not catching that during the internal review:

> +/* Broadcom Cygnus Phy specific registers */
> +#define MII_BCM_CORE_BASE1E       0x1E /* Core BASE1E register */
> +#define MII_BCM_EXPB0             0xB0 /* EXPB0 register */
> +#define MII_BCM_EXPB1             0xB1 /* EXPB1 register */

These defines could be moved to brcmphy.h for instance, since they are
shared between all Broadcom PHY drivers AFAICT.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
