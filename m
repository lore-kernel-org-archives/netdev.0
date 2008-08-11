From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [NET]: remove unnecessary #include
Date: Mon, 11 Aug 2008 08:34:41 +0200
Message-ID: <200808110834.42768.florian.fainelli@telecomint.eu>
References: <20080811125623.03D5.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, jgarzik@pobox.com, jgarzik@redhat.com,
	netdev@vger.kernel.org
To: Huang Weiyi <weiyi.huang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:58229 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbYHKGff convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 02:35:35 -0400
In-Reply-To: <20080811125623.03D5.WEIYI.HUANG@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Huang,

Le Monday 11 August 2008 06:56:44 Huang Weiyi, vous avez =E9crit=A0:
> The drivers below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
>   drivers/net/acenic.c
>   drivers/net/bnx2x_link.c
>   drivers/net/bnx2x_main.c
>   drivers/net/cpmac.c
>   drivers/net/gianfar_sysfs.c
>   drivers/net/ipg.h
>   drivers/net/ppp_mppe.c
>   drivers/net/pppol2tp.c
>   drivers/net/r6040.c

The r6040 driver can have more include files removed. Patch attached be=
low.
--
=46rom: Florian Fainelli
Subject: [PATCH] r6040: remove unused includes

This patch removes all unused includes.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
--
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 6531ff5..d453987 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -24,13 +24,9 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
-#include <linux/moduleparam.h>
-#include <linux/string.h>
 #include <linux/timer.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
-#include <linux/slab.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
@@ -45,9 +41,6 @@
 #include <linux/bitops.h>
 #include <linux/io.h>
 #include <linux/irq.h>
-#include <linux/uaccess.h>
-
-#include <asm/processor.h>
=20
 #define DRV_NAME	"r6040"
 #define DRV_VERSION	"0.18"
