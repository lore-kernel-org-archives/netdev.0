From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH] ethtool: Fix space-after-if checkpatch errors
Date: Tue, 22 Jan 2013 21:04:50 +0000
Message-ID: <1358888690-3140-1-git-send-email-mark.einon@gmail.com>
Cc: netdev@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:56917 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab3AVVE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 16:04:56 -0500
Received: by mail-wg0-f50.google.com with SMTP id es5so653630wgb.17
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 13:04:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some version check statements are lacking a space after the if ()
statement. Add them in.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 e100.c   |    2 +-
 e1000.c  |    2 +-
 et131x.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/e100.c b/e100.c
index 65627ab..b982e79 100644
--- a/e100.c
+++ b/e100.c
@@ -46,7 +46,7 @@ e100_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	u32 reg;
 	u16 scb_status, scb_cmd;
 
-	if(version != 1)
+	if (version != 1)
 		return -1;
 
 	reg = regs_buff[0];
diff --git a/e1000.c b/e1000.c
index d1d3c73..dd47774 100644
--- a/e1000.c
+++ b/e1000.c
@@ -374,7 +374,7 @@ e1000_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	enum e1000_mac_type mac_type;
 	u32 reg;
 
-	if(version != 1)
+	if (version != 1)
 		return -1;
 
 	mac_type = e1000_get_mac_type(hw_device_id, hw_revision_id);
diff --git a/et131x.c b/et131x.c
index 8cdbec0..36abaa2 100644
--- a/et131x.c
+++ b/et131x.c
@@ -7,7 +7,7 @@ int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	u8 version = (u8)(regs->version >> 24);
 	u32 *reg = (u32 *)regs->data;
 
-	if(version != 1)
+	if (version != 1)
 		return -1;
 
 	fprintf(stdout, "PHY Registers\n");
-- 
1.7.10.4
