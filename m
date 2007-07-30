From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 2/4][RFC] lro: Kconfig and Makefile
Date: Mon, 30 Jul 2007 17:24:45 +0200
Message-ID: <200707301724.45781.ossthema@de.ibm.com>
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
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:31743 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760067AbXG3Pxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 11:53:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kconfig and Makefile for LRO

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 net/ipv4/Kconfig  |    8 ++++++++
 net/ipv4/Makefile |    1 +
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index fb79097..d894f61 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -394,6 +394,14 @@ config INET_XFRM_MODE_BEET
 
 	  If unsure, say Y.
 
+config INET_LRO
+	tristate "Large Receive Offload (ipv4/tcp)"
+
+	---help---
+	  Support for Large Receive Offload (ipv4/tcp).
+
+	  If unsure, say Y.
+
 config INET_DIAG
 	tristate "INET: socket monitoring interface"
 	default y
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index fbf1674..a02c36d 100644
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

