From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/3] r8169:fix kernel log spam when set or get
 hardware wol setting.
Date: Thu, 28 Jul 2016 00:18:04 +0200
Message-ID: <20160727221804.GA3564@electric-eye.fr.zoreil.com>
References: <1469637668-8751-1-git-send-email-hau@realtek.com>
 <1469637668-8751-2-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1469637668-8751-2-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 0e62d74..f07604f 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1749,13 +1749,21 @@ static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
>  static void rtl8169_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
> +	struct pci_dev *pdev = tp->pci_dev;

Nit: you may directly use "struct device *d = &tp->pci_dev->dev;"

-- 
Ueimor
