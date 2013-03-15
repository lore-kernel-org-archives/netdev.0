From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 6/6] openvswitch: remove some useless comments
Date: Thu, 14 Mar 2013 17:15:06 -0700
Message-ID: <1363306506-885-7-git-send-email-jesse@nicira.com>
References: <1363306506-885-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1363306506-885-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

These comments are useless in upstream kernel.

Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/vport-netdev.c |    3 +--
 net/openvswitch/vport.c        |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

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
-- 
1.7.10.4
