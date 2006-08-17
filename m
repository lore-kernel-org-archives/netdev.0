From: "Joerg Dorchain" <joerg@dorchain.net>
Subject: Re: [RFC][PATCH 47/75] net: drivers/net/wireless/orinoco_tmd.c
     pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 16:35:58 +0200 (CEST)
Message-ID: <11849.158.169.9.14.1155825358.squirrel@www.dorchain.net>
References: <20060817132842.47.NURIpB4835.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: joerg@dorchain.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from RedStar.dorchain.net ([212.88.133.153]:16283 "EHLO
	Redstar.dorchain.net") by vger.kernel.org with ESMTP
	id S932199AbWHQOgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 10:36:03 -0400
In-Reply-To: <20060817132842.47.NURIpB4835.3636.michal@euridica.enternet.net.pl>
To: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

Fine with me.
Signed-off-by: Joerg Dorchain <joerg@dorchain.net>

>
> diff -uprN -X linux-work/Documentation/dontdiff
> linux-work-clean/drivers/net/wireless/orinoco_tmd.c
> linux-work2/drivers/net/wireless/orinoco_tmd.c
> --- linux-work-clean/drivers/net/wireless/orinoco_tmd.c	2006-08-16
> 22:41:00.000000000 +0200
> +++ linux-work2/drivers/net/wireless/orinoco_tmd.c	2006-08-17
> 05:20:37.000000000 +0200
> @@ -228,7 +228,7 @@ MODULE_LICENSE("Dual MPL/GPL");
>  static int __init orinoco_tmd_init(void)
>  {
>  	printk(KERN_DEBUG "%s\n", version);
> -	return pci_module_init(&orinoco_tmd_driver);
> +	return pci_register_driver(&orinoco_tmd_driver);
>  }
>
>  static void __exit orinoco_tmd_exit(void)
>


