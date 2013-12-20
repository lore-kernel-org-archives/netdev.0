From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH 1/2] llc: "foo* bar" should be "foo *bar"
Date: Fri, 20 Dec 2013 11:14:59 +0800
Message-ID: <1387509300-11940-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42003 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab3LTDPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 22:15:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>


Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/llc/llc_conn.c | 4 ++--
 net/llc/llc_core.c | 2 +-
 net/llc/llc_sap.c  | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index cd87241..42dc2e4 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -753,7 +753,7 @@ void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk)
  *
  *	Sends received pdus to the connection state machine.
  */
-static int llc_conn_rcv(struct sock* sk, struct sk_buff *skb)
+static int llc_conn_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct llc_conn_state_ev *ev = llc_conn_ev(skb);
 
@@ -891,7 +891,7 @@ out_kfree_skb:
  *
  *     Initializes a socket with default llc values.
  */
-static void llc_sk_init(struct sock* sk)
+static void llc_sk_init(struct sock *sk)
 {
 	struct llc_sock *llc = llc_sk(sk);
 
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 2bb0ddf..e251c04 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -48,7 +48,7 @@ static struct llc_sap *llc_sap_alloc(void)
 
 static struct llc_sap *__llc_sap_find(unsigned char sap_value)
 {
-	struct llc_sap* sap;
+	struct llc_sap *sap;
 
 	list_for_each_entry(sap, &llc_sap_list, node)
 		if (sap->laddr.lsap == sap_value)
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index e585069..06033f6 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -66,7 +66,7 @@ struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
 	return skb;
 }
 
-void llc_save_primitive(struct sock *sk, struct sk_buff* skb, u8 prim)
+void llc_save_primitive(struct sock *sk, struct sk_buff *skb, u8 prim)
 {
 	struct sockaddr_llc *addr;
 
@@ -114,7 +114,7 @@ void llc_sap_rtn_pdu(struct llc_sap *sap, struct sk_buff *skb)
  *	failure.
  */
 static struct llc_sap_state_trans *llc_find_sap_trans(struct llc_sap *sap,
-						      struct sk_buff* skb)
+						      struct sk_buff *skb)
 {
 	int i = 0;
 	struct llc_sap_state_trans *rc = NULL;
-- 
1.7.12
