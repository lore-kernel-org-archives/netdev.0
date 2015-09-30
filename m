From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 3/4] cxgb4: Adds a new Device Log Facility FW_DEVLOG_FACILITY_CF
Date: Wed, 30 Sep 2015 20:33:30 +0530
Message-ID: <1443625411-12096-4-git-send-email-hariprasad@chelsio.com>
References: <1443625411-12096-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15187 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751279AbbI3PC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 11:02:57 -0400
In-Reply-To: <1443625411-12096-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware team added a new Device Log Facility FW_DEVLOG_FACILITY_CF,
but the driver has been decoding Device Log messages with that Facility as
"(NULL)", fixing it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 8001619..8f23abb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -940,6 +940,7 @@ static const char * const devlog_level_strings[] = {
 
 static const char * const devlog_facility_strings[] = {
 	[FW_DEVLOG_FACILITY_CORE]	= "CORE",
+	[FW_DEVLOG_FACILITY_CF]         = "CF",
 	[FW_DEVLOG_FACILITY_SCHED]	= "SCHED",
 	[FW_DEVLOG_FACILITY_TIMER]	= "TIMER",
 	[FW_DEVLOG_FACILITY_RES]	= "RES",
-- 
2.3.4
