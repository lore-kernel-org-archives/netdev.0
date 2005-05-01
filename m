From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [-mm patch] SIS900 must select MII
Date: Sun, 1 May 2005 18:43:46 +0200
Message-ID: <5c6061e021b4bd91a5b6ee47fbb7f575@brownhat.org>
References: <20050429231653.32d2f091.akpm@osdl.org> <20050430115249.GA3654@stusta.de>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@stusta.de>, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261683AbVEAQn5@vger.kernel.org>
In-Reply-To: <20050430115249.GA3654@stusta.de>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/apr/05, at 13:52, Adrian Bunk wrote:

> This patch fixes the following compile error caused by bk-netdev:
>
> <--  snip  -->
>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Daniele Venzano <venza@brownhat.org>


> --- linux-2.6.12-rc3-mm1/drivers/net/Kconfig.old	2005-04-30 
> 13:47:25.000000000 +0200
> +++ linux-2.6.12-rc3-mm1/drivers/net/Kconfig	2005-04-30 
> 13:47:48.000000000 +0200
> @@ -1543,8 +1543,9 @@
>  config SIS900
>  	tristate "SiS 900/7016 PCI Fast Ethernet Adapter support"
>  	depends on NET_PCI && PCI
>  	select CRC32
> +	select MII
>  	---help---
>  	  This is a driver for the Fast Ethernet PCI network cards based on
>  	  the SiS 900 and SiS 7016 chips. The SiS 900 core is also embedded 
> in
>  	  SiS 630 and SiS 540 chipsets.  If you have one of those, say Y and
>
>
--
Daniele Venzano
http://www.brownhat.org
