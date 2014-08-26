From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/2] net: fix comments for __skb_flow_get_ports()
Date: Mon, 25 Aug 2014 17:03:46 -0700
Message-ID: <1409011427-18438-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:42939 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:04:00 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so21134420pdb.41
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 17:03:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit 690e36e726d00d2 (net: Allow raw buffers to be passed into the flow dissector)
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/flow_dissector.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 8ffcc97..ae8f0db 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -26,10 +26,12 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
 }
 
 /**
- * skb_flow_get_ports - extract the upper layer ports and return them
- * @skb: buffer to extract the ports from
+ * __skb_flow_get_ports - extract the upper layer ports and return them
+ * @skb: sk_buff to extract the ports from
  * @thoff: transport header offset
  * @ip_proto: protocol for which to get port offset
+ * @data: raw buffer pointer to the packet, if NULL use skb->data
+ * @hlen: packet header length, if @data is NULL use skb_headlen(skb)
  *
  * The function will try to retrieve the ports at offset thoff + poff where poff
  * is the protocol port offset returned from proto_ports_offset
-- 
1.8.3.1
