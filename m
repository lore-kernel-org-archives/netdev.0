From: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net: kill duplicate included head
Date: Tue, 17 Jan 2012 12:34:24 +0800
Message-ID: <4F14FA50.406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
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

From: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>


For net part, remove duplicate included head.


Signed-off-by: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
---
 net/caif/caif_usb.c    |    1 -
 net/ipv4/udp_diag.c    |    1 -
 net/openvswitch/flow.c |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 5fc9eca..3d737fb 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -11,7 +11,6 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/slab.h>
-#include <linux/netdevice.h>
 #include <linux/mii.h>
 #include <linux/usb.h>
 #include <linux/usb/usbnet.h>
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index e5e18cb..8a949f1 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -15,7 +15,6 @@
 #include <linux/udp.h>
 #include <net/udp.h>
 #include <net/udplite.h>
-#include <linux/inet_diag.h>
 #include <linux/sock_diag.h>

 static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fe7f020..1252c30 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -32,7 +32,6 @@
 #include <linux/in.h>
 #include <linux/rcupdate.h>
 #include <linux/if_arp.h>
-#include <linux/if_ether.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
-- 
1.7.1
