From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 13/13] udp_diag: Wire the udp_diag module into kbuild
Date: Fri, 09 Dec 2011 20:24:36 +0400
Message-ID: <4EE23644.2070104@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42984 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab1LIQYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:24:41 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Copy-s/tcp/udp/-paste from TCP bits.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/Kconfig  |    4 ++++
 net/ipv4/Makefile |    1 +
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index cbb505b..a51e33e 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -409,6 +409,10 @@ config INET_TCP_DIAG
 	depends on INET_DIAG
 	def_tristate INET_DIAG
 
+config INET_UDP_DIAG
+	depends on INET_DIAG
+	def_tristate INET_DIAG
+
 menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
 	---help---
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f2dc69c..e9d98e6 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter.o netfilter/
 obj-$(CONFIG_INET_DIAG) += inet_diag.o 
 obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
+obj-$(CONFIG_INET_UDP_DIAG) += udp_diag.o
 obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
-- 
1.5.5.6
