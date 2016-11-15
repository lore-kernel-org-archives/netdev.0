From: Heinrich Schuchardt <xypron.debian@gmx.de>
Subject: Re: [PATCH 03/15] net: bcm63xx_enet: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 20:59:00 +0100
Message-ID: <3dc4471a-1afd-0e28-1de9-60558cece143@gmx.de>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
 <20161115180644.3941-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        "maintainer:BROADCOM BCM63XX ARM ARCHITECTURE"
        <bcm-kernel-feedback-list@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>,
        Jarod Wilson <jarod@redhat.com>,
        Thierry Reding <treding@nvidia.com>,
        "moderated list:BROADCOM BCM63XX ARM ARCHITECTURE"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-4-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/2016 07:06 PM, Florian Fainelli wrote:
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Each patch of your patch series should have a commit message.

You can add the missing commit messages with
git rebase -i HEAD~15
choosing reword.

Please, add a cover letter message describing the patch series using

git format-patch -ns --cover-letter HEAD~15..HEAD

and provide a summary in the 0/15 message.

The cover letter and all patches should be in one mails thhread.
If you put all messages into one directory you can send the series as
one mail thread with

git send-email <directory>

> ---
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> index 5c7acef1de2e..a43ab90c051e 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -1434,11 +1434,8 @@ static int bcm_enet_nway_reset(struct net_device *dev)
>  	struct bcm_enet_priv *priv;
>  
>  	priv = netdev_priv(dev);
> -	if (priv->has_phy) {
> -		if (!dev->phydev)
> -			return -ENODEV;
> -		return genphy_restart_aneg(dev->phydev);
> -	}
> +	if (priv->has_phy)
> +		return phy_ethtool_nway_reset(dev),
>  
>  	return -EOPNOTSUPP;
>  }
> 
