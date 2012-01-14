From: Devendra Naga <devendra.aaru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] remove version.h includes in net/openvswitch/
Date: Sat, 14 Jan 2012 23:46:21 +0530
Message-ID: <1326564981-7142-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devendra.aaru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

remove version.h includes in net/openswitch/ as reported by make versioncheck.

Signed-off-by: Devendra Naga <devendra.aaru-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/datapath.c           |    1 -
 net/openvswitch/datapath.h           |    1 -
 net/openvswitch/vport-internal_dev.c |    1 -
 net/openvswitch/vport.c              |    1 -
 4 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 9a27251..d9d01cb 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -36,7 +36,6 @@
 #include <linux/rcupdate.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
-#include <linux/version.h>
 #include <linux/ethtool.h>
 #include <linux/wait.h>
 #include <asm/system.h>
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 5b9f884..c73370c 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -25,7 +25,6 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/u64_stats_sync.h>
-#include <linux/version.h>
 
 #include "flow.h"
 
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 8fc28b8..322b8d2 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -23,7 +23,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/skbuff.h>
-#include <linux/version.h>
 
 #include "datapath.h"
 #include "vport-internal_dev.h"
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 7f0ef37..6c066ba 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -27,7 +27,6 @@
 #include <linux/rcupdate.h>
 #include <linux/rtnetlink.h>
 #include <linux/compat.h>
-#include <linux/version.h>
 
 #include "vport.h"
 #include "vport-internal_dev.h"
-- 
1.7.1
