From: Sergey Matyukevich <geomatsi@gmail.com>
Subject: [PATCH] ucc_geth: fix UCC device number in debug message
Date: Wed, 28 Jul 2010 22:05:21 +0400
Message-ID: <1280340321-20276-1-git-send-email-geomatsi@gmail.com>
Cc: Li Yang <leoli@freescale.com>,
	Sergey Matyukevich <geomatsi@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48381 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab0G1SJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 14:09:24 -0400
Received: by eya25 with SMTP id 25so1146764eya.19
        for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 11:09:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains a fix for UCC device number in verbose debug message.

Signed-off-by: Sergey Matyukevich <geomatsi@gmail.com>

---
 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 807470e..ca1f36d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -594,7 +594,7 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 {
 	int i;
 
-	ugeth_info("UCC%d Geth registers:", ugeth->ug_info->uf_info.ucc_num);
+	ugeth_info("UCC%d Geth registers:", ugeth->ug_info->uf_info.ucc_num + 1);
 	ugeth_info("Base address: 0x%08x", (u32) ugeth->ug_regs);
 
 	ugeth_info("maccfg1    : addr - 0x%08x, val - 0x%08x",
-- 
1.6.2.5

