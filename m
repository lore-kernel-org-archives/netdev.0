From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] drivers/net/s2io.c: make bus_speed[] static
Date: Tue, 16 May 2006 17:30:50 +0200
Message-ID: <20060516153050.GC5677@stusta.de>
References: <20060515005637.00b54560.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932096AbWEPPax@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>,
	Ananda Raju <ananda.raju@neterion.com>, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20060515005637.00b54560.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 12:56:37AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.17-rc3-mm1:
>...
>  git-netdev-all.patch
>...
>  git trees
>...


This patch makes the needlessly global bus_speed[] static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-rc4-mm1-full/drivers/net/s2io.c.old	2006-05-16 13:06:58.000000000 +0200
+++ linux-2.6.17-rc4-mm1-full/drivers/net/s2io.c	2006-05-16 13:07:08.000000000 +0200
@@ -852,7 +852,7 @@
 	return 0;
 }
 
-int bus_speed[8] = {33, 133, 133, 200, 266, 133, 200, 266};
+static int bus_speed[8] = {33, 133, 133, 200, 266, 133, 200, 266};
 /**
  * s2io_print_pci_mode -
  */
