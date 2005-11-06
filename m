From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [2.6 patch] rename hostap.c to hostap_main.c
Date: Sat, 5 Nov 2005 20:15:43 -0800
Message-ID: <20051106041543.GC8972@jm.kir.nu>
References: <20051106005343.GF3668@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, hostap@shmoo.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051106005343.GF3668@stusta.de>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Sun, Nov 06, 2005 at 01:53:43AM +0100, Adrian Bunk wrote:
> I wanted to remove the #include "hostap_ioctl.c" from hostap.c and build 
> hostap_ioctl.c separately, but this doesn't work since hostap.c has the 
> same name as the module.

Is this patch changing anything in hostap.c or is it just a rename of
the file? Patch file is not exactly ideal for this kind of changes and I
hope git has a better way of storing this kind of rename.

I would rather not rename the file, but if this is the only way of
getting the module built in pieces, I'm okay with the change (assuming
nothing else changed in hostap.c in this changeset).


> +++ linux-2.6.14-rc5-mm1-full/drivers/net/wireless/hostap/Makefile	2005-11-06 00:14:57.000000000 +0100
> @@ -1,5 +1,7 @@
> -obj-$(CONFIG_HOSTAP_CS) += hostap_cs.o
> -obj-$(CONFIG_HOSTAP_PLX) += hostap_plx.o
> -obj-$(CONFIG_HOSTAP_PCI) += hostap_pci.o
> +obj-$(CONFIG_HOSTAP)		+= hostap.o
> +
> +obj-$(CONFIG_HOSTAP_CS)		+= hostap_cs.o
> +obj-$(CONFIG_HOSTAP_PLX)	+= hostap_plx.o
> +obj-$(CONFIG_HOSTAP_PCI)	+= hostap_pci.o

Why were the hostap_{cs,plx,pci} lines changed? I prefer the original
version of those lines (i.e., no extra padding).

-- 
Jouni Malinen                                            PGP id EFC895FA
