From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH 24/50] sis900: use dev_hw_addr_random() instead of random_ether_addr()
Date: Sat, 11 Feb 2012 10:05:15 +0100
Message-ID: <4F362F4B.4060903@brownhat.org>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <1328735457-29986-25-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-25-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il 08.02.2012 22:10, Danny Kukawka ha scritto:

> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.

Acked-by: Daniele Venzano <venza@brownhat.org>

> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/ethernet/sis/sis900.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
> index c8efc70..cbd0343 100644
> --- a/drivers/net/ethernet/sis/sis900.c
> +++ b/drivers/net/ethernet/sis/sis900.c
> @@ -527,7 +527,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
>  		ret = sis900_get_mac_addr(pci_dev, net_dev);
>  
>  	if (!ret || !is_valid_ether_addr(net_dev->dev_addr)) {
> -		random_ether_addr(net_dev->dev_addr);
> +		dev_hw_addr_random(net_dev, net_dev->dev_addr);
>  		printk(KERN_WARNING "%s: Unreadable or invalid MAC address,"
>  				"using random generated one\n", dev_name);
>  	}
