From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 02/15] be2net: endianness fix in be_cmd_set_qos().
Date: Fri, 11 Feb 2011 17:33:02 -0600
Message-ID: <20110211233302.GA18296@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51117 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757231Ab1BKXdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:33:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index a179cc6..d3b671d 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1868,8 +1868,8 @@ int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain)
 			OPCODE_COMMON_SET_QOS, sizeof(*req));
 
 	req->hdr.domain = domain;
-	req->valid_bits = BE_QOS_BITS_NIC;
-	req->max_bps_nic = bps;
+	req->valid_bits = cpu_to_le32(BE_QOS_BITS_NIC);
+	req->max_bps_nic = cpu_to_le32(bps);
 
 	status = be_mcc_notify_wait(adapter);
 
-- 
1.7.1

