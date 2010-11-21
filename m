From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/62] 3c527: Use static const
Date: Sat, 20 Nov 2010 18:38:05 -0800
Message-ID: <c088142e1410686b6598a92392d80dcf4110062d.1290305775.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1632 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095Ab0KUCjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:39:44 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  11256	    114	   2256	  13626	   353a	drivers/net/3c527.o.old
  11256	    114	   2256	  13626	   353a	drivers/net/3c527.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/3c527.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index 013b7c3..8c094ba 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -317,13 +317,13 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	u8 POS;
 	u32 base;
 	struct mc32_local *lp = netdev_priv(dev);
-	static u16 mca_io_bases[]={
+	static const u16 mca_io_bases[] = {
 		0x7280,0x7290,
 		0x7680,0x7690,
 		0x7A80,0x7A90,
 		0x7E80,0x7E90
 	};
-	static u32 mca_mem_bases[]={
+	static const u32 mca_mem_bases[] = {
 		0x00C0000,
 		0x00C4000,
 		0x00C8000,
@@ -333,7 +333,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 		0x00D8000,
 		0x00DC000
 	};
-	static char *failures[]={
+	static const char * const failures[] = {
 		"Processor instruction",
 		"Processor data bus",
 		"Processor data bus",
-- 
1.7.3.2.245.g03276.dirty

