From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: micrel: remove suspend/resume
Date: Tue, 23 Aug 2016 12:03:34 -0700
Message-ID: <2ee9441d-1b3b-de6d-691d-b615c04c69d0@gmail.com>
References: <20160823111344.25FF41A2459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        xander.huff@ni.com, brad.mouring@ni.com, nathan.sullivan@ni.com
To: Christophe Leroy <christophe.leroy@c-s.fr>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160823111344.25FF41A2459@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+others,

On 08/23/2016 04:13 AM, Christophe Leroy wrote:
> In ERRATA DS80000700A dated 05 May 2016, Microship recommends to
> not use software power down mode on KSZ8041 family.

s/Microship/Microchip/

> They say they have no plan to fix this ERRATA in future releases.

The errata applies to specific revisions, is this revision present in
the lower 4 bits of the MII_PHYSID2 register such that it could be used
to key the disabling of the power down?

> 
> http://ww1.microchip.com/downloads/en/DeviceDoc/80000700A.pdf
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  drivers/net/phy/micrel.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 053e879..f456c55 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -837,8 +837,6 @@ static struct phy_driver ksphy_driver[] = {
>  	.get_sset_count = kszphy_get_sset_count,
>  	.get_strings	= kszphy_get_strings,
>  	.get_stats	= kszphy_get_stats,
> -	.suspend	= genphy_suspend,
> -	.resume		= genphy_resume,
>  }, {
>  	.phy_id		= PHY_ID_KSZ8041RNLI,
>  	.phy_id_mask	= MICREL_PHY_ID_MASK,
> @@ -856,8 +854,6 @@ static struct phy_driver ksphy_driver[] = {
>  	.get_sset_count = kszphy_get_sset_count,
>  	.get_strings	= kszphy_get_strings,
>  	.get_stats	= kszphy_get_stats,
> -	.suspend	= genphy_suspend,
> -	.resume		= genphy_resume,
>  }, {
>  	.phy_id		= PHY_ID_KSZ8051,
>  	.phy_id_mask	= MICREL_PHY_ID_MASK,
> 


-- 
Florian
