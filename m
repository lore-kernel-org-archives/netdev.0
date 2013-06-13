From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 10/12] openvswitch: Expand action buffer
	size.
Date: Thu, 13 Jun 2013 11:25:05 -0700
Message-ID: <1371147905-9481-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

MAX_ACTIONS_BUFSIZE limits action list size, set tunnel action
needs extra space on action list, for now increase max actions list limit.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 5183935..b1bb01b 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -159,7 +159,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
 				  const struct nlattr *attr);
 
-#define MAX_ACTIONS_BUFSIZE    (16 * 1024)
+#define MAX_ACTIONS_BUFSIZE    (32 * 1024)
 #define TBL_MIN_BUCKETS		1024
 
 struct flow_table {
-- 
1.7.1
