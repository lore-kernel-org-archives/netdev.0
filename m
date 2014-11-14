From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] openvswitch: use PTR_ERR_OR_ZERO
Date: Fri, 14 Nov 2014 19:32:58 +0100
Message-ID: <1415989978-28559-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, dev@openvswitch.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/openvswitch/flow_netlink.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c0d066d..c8fccdd 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1425,10 +1425,8 @@ static int add_action(struct sw_flow_actions **sfa, int attrtype,
 	struct nlattr *a;
 
 	a = __add_action(sfa, attrtype, data, len, log);
-	if (IS_ERR(a))
-		return PTR_ERR(a);
 
-	return 0;
+	return PTR_ERR_OR_ZERO(a);
 }
 
 static inline int add_nested_action_start(struct sw_flow_actions **sfa,
-- 
1.9.3
