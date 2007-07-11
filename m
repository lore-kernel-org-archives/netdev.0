From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [RFC 2/3] lro: Kconfig and Makefile
Date: Wed, 11 Jul 2007 16:21:41 +0200
Message-ID: <200707111621.41800.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:25582 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763509AbXGKOrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 10:47:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kconfig and Makefile changes for LRO

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---
 net/ipv4/Kconfig  |    9 +++++++++
 net/ipv4/Makefile |    1 +
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 010fbb2..25279f4 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -436,6 +436,15 @@ config INET_XFRM_MODE_BEET
 
 	  If unsure, say Y.
 
+config INET_LRO
+	tristate "Large Receive Offload (tcp)"
+	default y
+
+	---help---
+	  Support for Large Receive Offload (tcp).
+
+	  if unsure, say Y.
+
 config INET_DIAG
 	tristate "INET: socket monitoring interface"
 	default y
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4ff6c15..a8f6d51 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -25,6 +25,7 @@ obj-$(CONFIG_INET_ESP) += esp4.o
 obj-$(CONFIG_INET_IPCOMP) += ipcomp.o
 obj-$(CONFIG_INET_XFRM_TUNNEL) += xfrm4_tunnel.o
 obj-$(CONFIG_INET_XFRM_MODE_BEET) += xfrm4_mode_beet.o
+obj-$(CONFIG_INET_LRO) += inet_lro.o
 obj-$(CONFIG_INET_TUNNEL) += tunnel4.o
 obj-$(CONFIG_INET_XFRM_MODE_TRANSPORT) += xfrm4_mode_transport.o
 obj-$(CONFIG_INET_XFRM_MODE_TUNNEL) += xfrm4_mode_tunnel.o
-- 
1.5.2

