From: Jim Cromie <jim.cromie@gmail.com>
Subject: [PATCH 05/11] broadcom: replace open-coded ARRAY_SIZE with macro
Date: Tue, 10 Apr 2012 18:56:03 -0600
Message-ID: <1334105763-9198-1-git-send-email-jim.cromie@gmail.com>
Cc: trivial@vger.kernel.org, Jim Cromie <jim.cromie@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64019 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756820Ab2DKA4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 20:56:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jim Cromie <jim.cromie@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 8297e28..0552168 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7343,8 +7343,7 @@ static struct {
 	{ "rx_fw_discards" },
 };
 
-#define BNX2_NUM_STATS (sizeof(bnx2_stats_str_arr)/\
-			sizeof(bnx2_stats_str_arr[0]))
+#define BNX2_NUM_STATS ARRAY_SIZE(bnx2_stats_str_arr)
 
 #define STATS_OFFSET32(offset_name) (offsetof(struct statistics_block, offset_name) / 4)
 
-- 
1.7.8.1
