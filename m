From: Jean Sacren <sakiwit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net 3/3] openvswitch: fix duplicate #include
	headers
Date: Thu,  7 Aug 2014 06:50:44 -0600
Message-ID: <1407415846-10277-2-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

The #include headers net/genetlink.h and linux/genetlink.h both were
included twice, so delete each of the duplicate.

Signed-off-by: Jean Sacren <sakiwit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
---
 net/openvswitch/datapath.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7ad3f029baae..7228ec3faf19 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -31,40 +31,38 @@
 #include <linux/genetlink.h>
 #include <linux/kernel.h>
 #include <linux/kthread.h>
 #include <linux/mutex.h>
 #include <linux/percpu.h>
 #include <linux/rcupdate.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/ethtool.h>
 #include <linux/wait.h>
 #include <asm/div64.h>
 #include <linux/highmem.h>
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/inetdevice.h>
 #include <linux/list.h>
 #include <linux/openvswitch.h>
 #include <linux/rculist.h>
 #include <linux/dmi.h>
-#include <linux/genetlink.h>
-#include <net/genetlink.h>
 #include <net/genetlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
 #include "datapath.h"
 #include "flow.h"
 #include "flow_table.h"
 #include "flow_netlink.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
 int ovs_net_id __read_mostly;
 
 static struct genl_family dp_packet_genl_family;
 static struct genl_family dp_flow_genl_family;
 static struct genl_family dp_datapath_genl_family;
 
 static const struct genl_multicast_group ovs_dp_flow_multicast_group = {
 	.name = OVS_FLOW_MCGROUP,
