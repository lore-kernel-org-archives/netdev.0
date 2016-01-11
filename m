From: Janusz Wolak <januszvdm@awokados.com.pl>
Subject: [PATCH] Remove line over 80 characters and unnecessary braces
Date: Mon, 11 Jan 2016 23:20:43 +0100
Message-ID: <1452550846-3611-1-git-send-email-januszvdm@awokados.com.pl>
Cc: davem@davemloft.net, netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org, Janusz Wolak <januszvdm@gmail.com>,
	Janusz Wolak <januszvdm@awokados.com.pl>
To: pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Janusz Wolak <januszvdm@gmail.com>

Signed-off-by: Janusz Wolak <januszvdm@awokados.com.pl>
---
 net/openvswitch/actions.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index c88d0f2..28bc395 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -620,7 +620,8 @@ static int set_sctp(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
-static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *skb)
+static int ovs_vport_output(struct net *net, struct sock *sk,
+			    struct sk_buff *skb)
 {
 	struct ovs_frag_data *data = this_cpu_ptr(&ovs_frag_data_storage);
 	struct vport *vport = data->vport;
@@ -707,9 +708,8 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 		unsigned long orig_dst;
 		struct rt6_info ovs_rt;
 
-		if (!v6ops) {
+		if (!v6ops)
 			goto err;
-		}
 
 		prepare_frag(vport, skb);
 		memset(&ovs_rt, 0, sizeof(ovs_rt));
-- 
2.5.0
