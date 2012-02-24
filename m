From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 4/5] be2net: enable RSS for ipv6 pkts
Date: Fri, 24 Feb 2012 10:20:16 +0530
Message-ID: <1330059017-5976-5-git-send-email-sathya.perla@emulex.com>
References: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:20274 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755089Ab2BXEzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 23:55:43 -0500
In-Reply-To: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 6432efa..398fb5c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1694,7 +1694,8 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 		OPCODE_ETH_RSS_CONFIG, sizeof(*req), wrb, NULL);
 
 	req->if_id = cpu_to_le32(adapter->if_handle);
-	req->enable_rss = cpu_to_le16(RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4);
+	req->enable_rss = cpu_to_le16(RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4 |
+				      RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6);
 	req->cpu_table_size_log2 = cpu_to_le16(fls(table_size) - 1);
 	memcpy(req->cpu_table, rsstable, table_size);
 	memcpy(req->hash, myhash, sizeof(myhash));
-- 
1.7.4
