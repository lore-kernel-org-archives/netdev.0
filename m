From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about samsung/sxgbe/sxgbe_xpcs.c
Date: Tue, 19 Jan 2016 17:26:17 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1601191723250.2531@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:49599 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754317AbcASQ0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 11:26:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was windering what is the purpose of the file
drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c

I can't find anything that refers to it, and if I remove it from the
makefile:

@@ -1,4 +1,4 @@
 obj-$(CONFIG_SXGBE_ETH) += samsung-sxgbe.o
 samsung-sxgbe-objs:= sxgbe_platform.o sxgbe_main.o sxgbe_desc.o \
                sxgbe_dma.o sxgbe_core.o sxgbe_mtl.o  sxgbe_mdio.o \
-               sxgbe_ethtool.o sxgbe_xpcs.o $(samsung-sxgbe-y)
+               sxgbe_ethtool.o $(samsung-sxgbe-y)

and then make clean and recompile, I see no bad effect.

thanks,
julia
