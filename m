From: Brice Goglin <brice@myri.com>
Subject: [PATCH 04/16] myri10ge: properly align scratch buffers
Date: Fri, 09 May 2008 02:17:37 +0200
Message-ID: <48239821.10405@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763485AbYEIAqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:11 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly align scratch buffers when making boot commands.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:02:04.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:03:32.000000000 +0200
@@ -443,7 +443,7 @@
 static void myri10ge_dummy_rdma(struct myri10ge_priv *mgp, int enable)
 {
 	char __iomem *submit;
-	__be32 buf[16];
+	__be32 buf[16] __attribute__ ((__aligned__(8)));
 	u32 dma_low, dma_high;
 	int i;
 
@@ -613,7 +613,7 @@
 static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 {
 	char __iomem *submit;
-	__be32 buf[16];
+	__be32 buf[16] __attribute__ ((__aligned__(8)));
 	u32 dma_low, dma_high, size;
 	int status, i;
 	struct myri10ge_cmd cmd;


