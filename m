From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [Patch RFC 10/10 v2] mlx4_en: Makefile and Kconfig
Date: Wed, 20 Aug 2008 16:01:27 +0300
Message-ID: <48AC15A7.7000204@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43961 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756347AbYHTNC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 09:02:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 10 Jul 2008 12:02:51 +0300
Subject: [PATCH] mlx4_en: Makefile and Kconfig

Changed Makefile and Kconfig files to enable mlx4_en compilation.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/Kconfig       |    9 +++++++++
 drivers/net/mlx4/Makefile |    5 +++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fa533c2..1dbbc1e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2464,6 +2464,15 @@ config PASEMI_MAC
 	  This driver supports the on-chip 1/10Gbit Ethernet controller on
 	  PA Semi's PWRficient line of chips.

+config MLX4_EN
+	tristate "Mellanox Technologies 10Gbit Ethernet support"
+	depends on PCI && INET
+	select MLX4_CORE
+	select INET_LRO
+	help
+	  This driver supports Mellanox Technologies ConnectX Ethernet
+	  devices.
+
 config MLX4_CORE
 	tristate
 	depends on PCI
diff --git a/drivers/net/mlx4/Makefile b/drivers/net/mlx4/Makefile
index 3f71687..16ffb1a 100644
--- a/drivers/net/mlx4/Makefile
+++ b/drivers/net/mlx4/Makefile
@@ -2,3 +2,8 @@ obj-$(CONFIG_MLX4_CORE)		+= mlx4_core.o

 mlx4_core-y :=	alloc.o catas.o cmd.o cq.o eq.o fw.o icm.o intf.o main.o mcg.o \
 		mr.o pd.o profile.o qp.o reset.o srq.o port.o sense.o
+
+obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
+
+mlx4_en-y := 	en_main.o en_tx.o en_rx.o en_params.o en_port.o en_cq.o \
+		en_resources.o en_netdev.o
-- 
1.5.4





