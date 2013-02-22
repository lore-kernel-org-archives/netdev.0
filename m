From: Cong Wang <amwang@redhat.com>
Subject: [Patch] openvswitch: remove some useless comments
Date: Fri, 22 Feb 2013 19:41:26 +0800
Message-ID: <1361533286-29210-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755951Ab3BVLlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 06:41:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

These comments are useless in upstream kernel.

Cc: David S. Miller <davem@davemloft.net>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 670cbc3..2130d61 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -43,8 +43,7 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 
 	/* Make our own copy of the packet.  Otherwise we will mangle the
 	 * packet for anyone who came before us (e.g. tcpdump via AF_PACKET).
-	 * (No one comes after us, since we tell handle_bridge() that we took
-	 * the packet.) */
+	 */
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
 		return;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 70af0be..6255e48 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -326,8 +326,7 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
  * @skb: skb that was received
  *
  * Must be called with rcu_read_lock.  The packet cannot be shared and
- * skb->data should point to the Ethernet header.  The caller must have already
- * called compute_ip_summed() to initialize the checksumming fields.
+ * skb->data should point to the Ethernet header.
  */
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
 {
