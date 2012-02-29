From: Florian Fainelli <ffainelli@freebox.fr>
Subject: Re: [PATCH 4/8] bcm63xx_enet: use dev_set_mac_address() instead of
 bcm_enet_set_mac_address()
Date: Wed, 29 Feb 2012 16:49:04 +0100
Message-ID: <4F4E48F0.80805@freebox.fr>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de> <1330530176-24952-5-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330530176-24952-5-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02/29/12 16:42, Danny Kukawka a =C3=A9crit :
> Use dev_set_mac_address() instead of bcm_enet_set_mac_address() direc=
tly
> to get validation checks for free.
>
> Signed-off-by: Danny Kukawka<danny.kukawka@bisect.de>

Acked-by: Florian Fainelli <ffainelli@freebox.fr>

> ---
>   drivers/net/ethernet/broadcom/bcm63xx_enet.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/n=
et/ethernet/broadcom/bcm63xx_enet.c
> index c7ca7ec..28184a8 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -858,7 +858,7 @@ static int bcm_enet_open(struct net_device *dev)
>
>   	/* write device mac address */
>   	memcpy(addr.sa_data, dev->dev_addr, ETH_ALEN);
> -	bcm_enet_set_mac_address(dev,&addr);
> +	dev_set_mac_address(dev,&addr);
>
>   	/* allocate rx dma ring */
>   	size =3D priv->rx_ring_size * sizeof(struct bcm_enet_desc);
