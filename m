From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH 6/6] myri10ge - Kconfig and Makefile
Date: Sat, 13 May 2006 20:51:57 +0200
Message-ID: <20060513185157.GC6931@stusta.de>
References: <446259A0.8050504@myri.com> <44625E9B.3090509@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964771AbWEMSv5@vger.kernel.org>
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <44625E9B.3090509@myri.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 10, 2006 at 11:43:55PM +0200, Brice Goglin wrote:
>...
> --- linux-mm/drivers/net/Makefile.old	2006-04-08 04:49:53.000000000 -0700
> +++ linux-mm/drivers/net/Makefile	2006-04-21 08:10:27.000000000 -0700
> @@ -192,6 +192,7 @@ obj-$(CONFIG_R8169) += r8169.o
>  obj-$(CONFIG_AMD8111_ETH) += amd8111e.o
>  obj-$(CONFIG_IBMVETH) += ibmveth.o
>  obj-$(CONFIG_S2IO) += s2io.o
> +obj-$(CONFIG_MYRI10GE) += myri10ge/
>  obj-$(CONFIG_SMC91X) += smc91x.o
>  obj-$(CONFIG_SMC911X) += smc911x.o
>  obj-$(CONFIG_DM9000) += dm9000.o
> --- /dev/null	2006-04-21 00:45:09.064430000 -0700
> +++ linux-mm/drivers/net/myri10ge/Makefile	2006-04-21 08:14:21.000000000 -0700
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the Myricom Myri-10G ethernet driver
> +#
> +
> +obj-$(CONFIG_MYRI10GE) += myri10ge.o

If the driver consists of one source file, why does it need an own 
subdir?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
