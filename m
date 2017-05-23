From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH ethtool 2/2] ethtool: add support for HWTSTAMP_FILTER_NTP_ALL
Date: Tue, 23 May 2017 16:29:30 +0200
Message-ID: <20170523142930.28181-3-mlichvar@redhat.com>
References: <20170523142930.28181-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        "John W . Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53656 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936543AbdEWO3f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 10:29:35 -0400
In-Reply-To: <20170523142930.28181-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add HWTSTAMP_FILTER_NTP_ALL to the list of hardware receive
filters which can be printed by ethtool -T.

CC: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index ad18704..85b320c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1589,7 +1589,7 @@ static char *tx_type_labels[N_TX_TYPES] = {
 	"one-step-sync         (HWTSTAMP_TX_ONESTEP_SYNC)",
 };
 
-#define N_RX_FILTERS (HWTSTAMP_FILTER_PTP_V2_DELAY_REQ + 1)
+#define N_RX_FILTERS (HWTSTAMP_FILTER_NTP_ALL + 1)
 
 static char *rx_filter_labels[N_RX_FILTERS] = {
 	"none                  (HWTSTAMP_FILTER_NONE)",
@@ -1607,6 +1607,7 @@ static char *rx_filter_labels[N_RX_FILTERS] = {
 	"ptpv2-event           (HWTSTAMP_FILTER_PTP_V2_EVENT)",
 	"ptpv2-sync            (HWTSTAMP_FILTER_PTP_V2_SYNC)",
 	"ptpv2-delay-req       (HWTSTAMP_FILTER_PTP_V2_DELAY_REQ)",
+	"ntp-all               (HWTSTAMP_FILTER_NTP_ALL)",
 };
 
 static int dump_tsinfo(const struct ethtool_ts_info *info)
-- 
2.9.3
