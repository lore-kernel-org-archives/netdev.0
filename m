From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 5/5] drivers: net: xgene: fix register offset
Date: Fri, 13 May 2016 16:53:01 -0700
Message-ID: <1463183581-30475-6-git-send-email-isubramanian@apm.com>
References: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33242 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbcEMXwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:52:11 -0400
Received: by mail-pf0-f179.google.com with SMTP id 206so47346916pfu.0
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:52:11 -0700 (PDT)
In-Reply-To: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes SG_RX_DV_GATE_REG_0_ADDR register offset
and ring state field lengths.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    | 6 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index ecfeffe..45220be 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -86,7 +86,7 @@ enum xgene_enet_rm {
 #define RINGADDRL_POS		5
 #define RINGADDRL_LEN		27
 #define RINGADDRH_POS		0
-#define RINGADDRH_LEN		6
+#define RINGADDRH_LEN		7
 #define RINGSIZE_POS		23
 #define RINGSIZE_LEN		3
 #define RINGTYPE_POS		19
@@ -94,9 +94,9 @@ enum xgene_enet_rm {
 #define RINGMODE_POS		20
 #define RINGMODE_LEN		3
 #define RECOMTIMEOUTL_POS	28
-#define RECOMTIMEOUTL_LEN	3
+#define RECOMTIMEOUTL_LEN	4
 #define RECOMTIMEOUTH_POS	0
-#define RECOMTIMEOUTH_LEN	2
+#define RECOMTIMEOUTH_LEN	3
 #define NUMMSGSINQ_POS		1
 #define NUMMSGSINQ_LEN		16
 #define ACCEPTLERR		BIT(19)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
index 29a71b4..002df5a 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
@@ -33,7 +33,7 @@
 #define LINK_STATUS			BIT(2)
 #define LINK_UP				BIT(15)
 #define MPA_IDLE_WITH_QMI_EMPTY		BIT(12)
-#define SG_RX_DV_GATE_REG_0_ADDR	0x0dfc
+#define SG_RX_DV_GATE_REG_0_ADDR	0x05fc
 
 extern const struct xgene_mac_ops xgene_sgmac_ops;
 extern const struct xgene_port_ops xgene_sgport_ops;
-- 
1.9.1
