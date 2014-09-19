From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 08/12] be2net: insert a blank line after function/struct//enum definitions
Date: Fri, 19 Sep 2014 15:46:58 +0530
Message-ID: <1411121822-25842-9-git-send-email-sathya.perla@emulex.com>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52817 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbaISKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:31 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch inserts a blank line after function/struct/union/enum definitions
as per checkpatch warnings.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    3 +++
 drivers/net/ethernet/emulex/benet/be_main.c    |    2 ++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 9a2a72b..42b10f9 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -130,6 +130,7 @@ static const struct be_ethtool_stat et_stats[] = {
 	{DRVSTAT_INFO(roce_drops_payload_len)},
 	{DRVSTAT_INFO(roce_drops_crc)}
 };
+
 #define ETHTOOL_STATS_NUM ARRAY_SIZE(et_stats)
 
 /* Stats related to multi RX queues: get_stats routine assumes bytes, pkts
@@ -152,6 +153,7 @@ static const struct be_ethtool_stat et_rx_stats[] = {
 	 */
 	{DRVSTAT_RX_INFO(rx_drops_no_frags)}
 };
+
 #define ETHTOOL_RXSTATS_NUM (ARRAY_SIZE(et_rx_stats))
 
 /* Stats related to multi TX queues: get_stats routine assumes compl is the
@@ -200,6 +202,7 @@ static const struct be_ethtool_stat et_tx_stats[] = {
 	/* Pkts dropped in the driver's transmit path */
 	{DRVSTAT_TX_INFO(tx_drv_drops)}
 };
+
 #define ETHTOOL_TXSTATS_NUM (ARRAY_SIZE(et_tx_stats))
 
 static const char et_self_tests[][ETH_GSTRING_LEN] = {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 8095c83..31b5fdc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -86,6 +86,7 @@ static const char * const ue_status_low_desc[] = {
 	"JTAG ",
 	"MPU_INTPEND "
 };
+
 /* UE Status High CSR */
 static const char * const ue_status_hi_desc[] = {
 	"LPCMEMHOST",
@@ -1424,6 +1425,7 @@ err:
 		max_tx_rate, vf);
 	return be_cmd_status(status);
 }
+
 static int be_set_vf_link_state(struct net_device *netdev, int vf,
 				int link_state)
 {
-- 
1.7.1
