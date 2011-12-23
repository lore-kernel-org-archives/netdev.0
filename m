From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: Correct register dump offsets for Intel 82575 chipsets.
Date: Fri, 23 Dec 2011 02:32:51 -0800
Message-ID: <1324636371-5402-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45231 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753723Ab1LWKc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 05:32:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

When support was added to dump the registers on 82575 chipset devices,
six register offsets (receive/transmit desc length, head, and tail)
were incorrectly mapped. This patch remaps the offsets to the correct
registers.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 igb.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/igb.c b/igb.c
index ec35d36..e0ccef9 100644
--- a/igb.c
+++ b/igb.c
@@ -200,13 +200,13 @@ igb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	/* Receive descriptor registers */
 	fprintf(stdout,
 		"0x02808: RDLEN  (Receive desc length)                 0x%08X\n",
-		regs_buff[142]);
+		regs_buff[137]);
 	fprintf(stdout,
 		"0x02810: RDH    (Receive desc head)                   0x%08X\n",
-		regs_buff[146]);
+		regs_buff[141]);
 	fprintf(stdout,
 		"0x02818: RDT    (Receive desc tail)                   0x%08X\n",
-		regs_buff[150]);
+		regs_buff[145]);
 
 	/* Transmit control register */
 	reg = regs_buff[38];
@@ -226,13 +226,13 @@ igb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	/* Transmit descriptor registers */
 	fprintf(stdout,
 		"0x03808: TDLEN       (Transmit desc length)           0x%08X\n",
-		regs_buff[214]);
+		regs_buff[219]);
 	fprintf(stdout,
 		"0x03810: TDH         (Transmit desc head)             0x%08X\n",
-		regs_buff[218]);
+		regs_buff[223]);
 	fprintf(stdout,
 		"0x03818: TDT         (Transmit desc tail)             0x%08X\n",
-		regs_buff[222]);
+		regs_buff[227]);
 
 
 	fprintf(stdout,
-- 
1.7.7.4
