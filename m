From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Subject: [patch 2/2] spidernet: introduce new setting
Date: Thu, 4 May 2006 05:59:56 -0400
Message-ID: <200605041159.57081.Jens.Osterkamp@de.ibm.com>
References: <20060504155034.486042000@>
Reply-To: Jens.Osterkamp@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arndb@de.ibm.com, utz.bacher@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:43137 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751469AbWEDJ77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 05:59:59 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k449xvfh148044
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 09:59:57 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k44A1AYd109376
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 12:01:10 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k449xv2E018447
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 11:59:57 +0200
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Osterkamp <jens.osterkamp@de.ibm.com>

We found a new chip setting that we need in order
to make the driver work more reliable.

Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>

Index: linux-2.6.17-rc3/drivers/net/spider_net.c
===================================================================
--- linux-2.6.17-rc3.orig/drivers/net/spider_net.c
+++ linux-2.6.17-rc3/drivers/net/spider_net.c
@@ -1652,6 +1652,8 @@ spider_net_enable_card(struct spider_net
 		{ SPIDER_NET_GFTRESTRT, SPIDER_NET_RESTART_VALUE },
 
 		{ SPIDER_NET_GMRWOLCTRL, 0 },
+		{ SPIDER_NET_GTESTMD, 0x10000000 },
+		{ SPIDER_NET_GTTQMSK, 0x00400040 },
 		{ SPIDER_NET_GTESTMD, 0 },
 
 		{ SPIDER_NET_GMACINTEN, 0 },
Index: linux-2.6.17-rc3/drivers/net/spider_net.h
===================================================================
--- linux-2.6.17-rc3.orig/drivers/net/spider_net.h
+++ linux-2.6.17-rc3/drivers/net/spider_net.h
@@ -120,6 +120,8 @@ extern char spider_net_driver_name[];
 #define SPIDER_NET_GMRUAFILnR		0x00000500
 #define SPIDER_NET_GMRUA0FIL15R		0x00000578
 
+#define SPIDER_NET_GTTQMSK		0x00000934
+
 /* RX DMA controller registers, all 0x00000a.. are for DMA controller A,
  * 0x00000b.. for DMA controller B, etc. */
 #define SPIDER_NET_GDADCHA		0x00000a00

--

