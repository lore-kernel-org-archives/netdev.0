From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 4/8] openvswitch: fix variable names in comment
Date: Fri, 14 Jun 2013 15:28:53 -0700
Message-ID: <1371248937-35614-5-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:40455 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753547Ab3FNW3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 18:29:08 -0400
Received: by mail-pa0-f44.google.com with SMTP id lj1so1059865pab.31
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 15:29:08 -0700 (PDT)
In-Reply-To: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorand Jakab <lojakab@cisco.com>

Signed-off-by: Lorand Jakab <lojakab@cisco.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index b15321a..33df091 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -590,10 +590,10 @@ out:
  *    - skb->network_header: just past the Ethernet header, or just past the
  *      VLAN header, to the first byte of the Ethernet payload.
  *
- *    - skb->transport_header: If key->dl_type is ETH_P_IP or ETH_P_IPV6
+ *    - skb->transport_header: If key->eth.type is ETH_P_IP or ETH_P_IPV6
  *      on output, then just past the IP header, if one is present and
  *      of a correct length, otherwise the same as skb->network_header.
- *      For other key->dl_type values it is left untouched.
+ *      For other key->eth.type values it is left untouched.
  */
 int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 		 int *key_lenp)
-- 
1.8.1.2
