From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy: micrel: Disable asymmetric pause for KSZ9031
Date: Thu, 11 Sep 2014 11:41:45 -0700
Message-ID: <5411ECE9.8050600@gmail.com>
References: <1410443140-2833-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Mike Looijmans <mike.looijmans@topic.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410443140-2833-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/11/2014 06:45 AM, Mike Looijmans wrote:
> Our KSZ9031 appears to suffer from the same hardware bug as described
> for the KSZ9021 in commit 32fcafbcd1c9f6c7013016a22a5369b4acb93577,
> you have to unplug the cable and plug it back to get it to work.
> 
> Remove the SUPPORTED_Asym_Pause flag for the KSZ9031 to fix this.

Can you resend this patch specifying the commit subject in parenthesis
like this:

commit 32fcafbcd1c9f6c7013016a22a5369b4acb93577 ("net/phy: micrel:
Disable asymmetric pause for KSZ9021")

since this is a bugfix, it should probably be targeting the 'net' tree,
rather than the 'net-next' tree, though the patch applies to both cleanly.

Other than that:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
> ---
>  drivers/net/phy/micrel.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 5a8993b..a932a35 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -425,8 +425,7 @@ static struct phy_driver ksphy_driver[] = {
>  	.phy_id		= PHY_ID_KSZ9031,
>  	.phy_id_mask	= 0x00fffff0,
>  	.name		= "Micrel KSZ9031 Gigabit PHY",
> -	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
> -				| SUPPORTED_Asym_Pause),
> +	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
>  	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
>  	.config_init	= kszphy_config_init,
>  	.config_aneg	= genphy_config_aneg,
> 
