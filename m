From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: Re: [PATCH v3] net/phy: micrel: Disable asymmetric pause for KSZ9031
Date: Mon, 15 Sep 2014 12:07:42 +0200
Message-ID: <5416BA6E.4080507@topic.nl>
References: <20140912.181820.1440041146938289489.davem@davemloft.net> <1410775594-3129-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	Mike Looijmans <mike.looijmans@topic.nl>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410775594-3129-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=EF=BB=BFI based this patch on the 3.17rc5 state. Hope this applies cle=
anly now?


On 09/15/2014 12:06 PM, Mike Looijmans wrote:
> The KSZ9031 appears to suffer from the same hardware bug as described
> for the KSZ9021 in commit 32fcafbcd1c9f6c7013016a22a5369b4acb93577
> ("net/phy: micrel: Disable asymmetric pause for KSZ9021")
> you have to unplug the cable and plug it back to get it to work.
>
> Remove the SUPPORTED_Asym_Pause flag for the KSZ9031 to fix this.
>
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
> ---
>   drivers/net/phy/micrel.c |    3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index fd0ea7c..011dbda 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -592,8 +592,7 @@ static struct phy_driver ksphy_driver[] =3D {
>   	.phy_id		=3D PHY_ID_KSZ9031,
>   	.phy_id_mask	=3D 0x00fffff0,
>   	.name		=3D "Micrel KSZ9031 Gigabit PHY",
> -	.features	=3D (PHY_GBIT_FEATURES | SUPPORTED_Pause
> -				| SUPPORTED_Asym_Pause),
> +	.features	=3D (PHY_GBIT_FEATURES | SUPPORTED_Pause),
>   	.flags		=3D PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
>   	.config_init	=3D ksz9031_config_init,
>   	.config_aneg	=3D genphy_config_aneg,
>



Met vriendelijke groet / kind regards,

Mike Looijmans

TOPIC Embedded Systems
Eindhovenseweg 32-C, NL-5683 KH Best
Postbus 440, NL-5680 AK Best
Telefoon: (+31) (0) 499 33 69 79
Telefax:  (+31) (0) 499 33 69 70
E-mail: mike.looijmans@topic.nl
Website: www.topic.nl

Please consider the environment before printing this e-mail

Topic zoekt gedreven (embedded) software specialisten!
http://topic.nl/vacatures/topic-zoekt-software-engineers/
