From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 05/11] openvswitch: Fix argument
	descriptions in vport.c.
Date: Tue, 27 Aug 2013 13:20:42 -0700
Message-ID: <1377634848-34327-6-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1377634848-34327-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/vport.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index d69e0c0..6f65dbe 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -203,7 +203,7 @@ out:
  *	ovs_vport_set_options - modify existing vport device (for kernel callers)
  *
  * @vport: vport to modify.
- * @port: New configuration.
+ * @options: New configuration.
  *
  * Modifies an existing device with the specified configuration (which is
  * dependent on device type).  ovs_mutex must be held.
@@ -328,6 +328,7 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
  *
  * @vport: vport that received the packet
  * @skb: skb that was received
+ * @tun_key: tunnel (if any) that carried packet
  *
  * Must be called with rcu_read_lock.  The packet cannot be shared and
  * skb->data should point to the Ethernet header.
-- 
1.8.1.2
