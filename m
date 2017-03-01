From: Peter Downs <padowns-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] Net: openvswitch: actions: fixed a brace coding
	style warning
Date: Wed,  1 Mar 2017 01:01:17 -0800
Message-ID: <1488358877-20762-1-git-send-email-padowns@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Peter Downs <padowns-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Fixed a brace coding style warning reported by checkpatch.pl

Signed-off-by: Peter Downs <padowns-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/actions.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b1beb2b..c82301c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -796,9 +796,8 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 		unsigned long orig_dst;
 		struct rt6_info ovs_rt;
 
-		if (!v6ops) {
+		if (!v6ops)
 			goto err;
-		}
 
 		prepare_frag(vport, skb, orig_network_offset,
 			     ovs_key_mac_proto(key));
-- 
2.1.4
