From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 7/8][ATM]: Trivial spelling fix patch for net/Kconfig
Date: Tue, 19 Jul 2005 16:46:15 -0400
Message-ID: <200507192046.j6JKkEc2027235@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: Trivial spelling fix patch for net/Kconfig

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit eefc05048924978c1e28835bf5085c5de2e653d2
tree b453e78b3eca05558e5c3ff8d9cf9ab9f2ee9bd9
parent ac4755cc8eefb198945e76d4069184454c0819ce
author chas williams <chas@relax.(none)> Tue, 19 Jul 2005 14:58:08 -0400
committer chas williams <chas@relax.(none)> Tue, 19 Jul 2005 14:58:08 -0400

 net/atm/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/atm/Kconfig b/net/atm/Kconfig
--- a/net/atm/Kconfig
+++ b/net/atm/Kconfig
@@ -60,7 +60,7 @@ config ATM_BR2684
 	tristate "RFC1483/2684 Bridged protocols"
 	depends on ATM && INET
 	help
-	  ATM PVCs can carry ethernet PDUs according to rfc2684 (formerly 1483)
+	  ATM PVCs can carry ethernet PDUs according to RFC2684 (formerly 1483)
 	  This device will act like an ethernet from the kernels point of view,
 	  with the traffic being carried by ATM PVCs (currently 1 PVC/device).
 	  This is sometimes used over DSL lines.  If in doubt, say N.
@@ -69,6 +69,6 @@ config ATM_BR2684_IPFILTER
 	bool "Per-VC IP filter kludge"
 	depends on ATM_BR2684
 	help
-	  This is an experimental mechanism for users who need to terminating a
+	  This is an experimental mechanism for users who need to terminate a
 	  large number of IP-only vcc's.  Do not enable this unless you are sure
 	  you know what you are doing.
