From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] ne: Do not use slashes in irq name string
Date: Wed, 17 Mar 2010 00:27:40 +0900
Message-ID: <1268753260-5632-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mv-drv-hcb004.ocn.ad.jp ([118.23.109.134]:53653 "EHLO
	mv-drv-hcb004.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966335Ab0CPP1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 11:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes following warning introduced by commit
12bac0d9f4dbf3445a0319beee848d15fa32775e ("proc: warn on non-existing
proc entries"):

WARNING: at /work/mips-linux/make/linux/fs/proc/generic.c:316 __xlate_proc_name+0xe0/0xe8()
name 'RBHMA4X00/RTL8019'

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/ne.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 992dbff..f4347f8 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -142,7 +142,7 @@ bad_clone_list[] __initdata = {
     {"PCM-4823", "PCM-4823", {0x00, 0xc0, 0x6c}}, /* Broken Advantech MoBo */
     {"REALTEK", "RTL8019", {0x00, 0x00, 0xe8}}, /* no-name with Realtek chip */
 #ifdef CONFIG_MACH_TX49XX
-    {"RBHMA4X00-RTL8019", "RBHMA4X00/RTL8019", {0x00, 0x60, 0x0a}},  /* Toshiba built-in */
+    {"RBHMA4X00-RTL8019", "RBHMA4X00-RTL8019", {0x00, 0x60, 0x0a}},  /* Toshiba built-in */
 #endif
     {"LCS-8834", "LCS-8836", {0x04, 0x04, 0x37}}, /* ShinyNet (SET) */
     {NULL,}
-- 
1.5.6.5

