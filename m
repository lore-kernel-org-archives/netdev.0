From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix broken compilation with
 CONFIG_BNX2X_SRIOV is not set
Date: Fri, 6 Sep 2013 10:35:28 +0300
Message-ID: <1378452928-6072-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3992 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717Ab3IFHgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 03:36:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 60cad4e67bd6ff400e7ea61fe762b3042b12ae9d
"bnx2x: VF RSS support - VF side" fails to compile w/o
CONFIG_BNX2X_SRIOV option.
 
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
Done with same formatting used in the file. 
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 2a8c1dc..059f0d4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -816,6 +816,8 @@ static inline int bnx2x_vfpf_setup_q(struct bnx2x *bp, struct bnx2x_fastpath *fp
 static inline int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx) {return 0; }
 static inline int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8 *addr,
 					u8 vf_qid, bool set) {return 0; }
+static inline int bnx2x_vfpf_config_rss(struct bnx2x *bp,
+					struct bnx2x_config_rss_params *params) {return 0; }
 static inline int bnx2x_vfpf_set_mcast(struct net_device *dev) {return 0; }
 static inline int bnx2x_vfpf_storm_rx_mode(struct bnx2x *bp) {return 0; }
 static inline int bnx2x_iov_nic_init(struct bnx2x *bp) {return 0; }
-- 
1.8.3.1
