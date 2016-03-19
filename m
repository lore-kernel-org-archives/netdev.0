From: Joe Perches <joe@perches.com>
Subject: [RFC net-next 2/2] chelsio: Move original cxgb driver into ancient subdirectory
Date: Fri, 18 Mar 2016 17:33:31 -0700
Message-ID: <be7008f6c47c3c8a7ebe81caf394106ff91ac099.1458347329.git.joe@perches.com>
References: <1458340518.26915.30.camel@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458340518.26915.30.camel@perches.com>
In-Reply-To: <cover.1458347329.git.joe@perches.com>
References: <cover.1458347329.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This hardware is no longer sold or supported by Chelsio.
The hardware is relatively rare, so move it to an ancient subdirectory.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/chelsio/Kconfig                                | 2 +-
 drivers/net/ethernet/chelsio/Makefile                               | 2 +-
 drivers/net/ethernet/chelsio/ancient/Makefile                       | 1 +
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/Makefile            | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/common.h            | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cphy.h              | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cpl5_cmd.h          | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cxgb2.c             | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/elmer0.h            | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/espi.c              | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/espi.h              | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/fpga_defs.h         | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/gmac.h              | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.c         | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.h         | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88x201x.c         | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/my3126.c            | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/pm3393.c            | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/regs.h              | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.c               | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.h               | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/subr.c              | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/suni1x10gexp_regs.h | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.c                | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.h                | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/vsc7326.c           | 0
 drivers/net/ethernet/chelsio/{ => ancient}/cxgb/vsc7326_reg.h       | 0
 27 files changed, 3 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/ancient/Makefile
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/Makefile (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/common.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cphy.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cpl5_cmd.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/cxgb2.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/elmer0.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/espi.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/espi.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/fpga_defs.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/gmac.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88e1xxx.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/mv88x201x.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/my3126.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/pm3393.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/regs.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/sge.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/subr.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/suni1x10gexp_regs.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/tp.h (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/vsc7326.c (100%)
 rename drivers/net/ethernet/chelsio/{ => ancient}/cxgb/vsc7326_reg.h (100%)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 4d187f2..25f4931 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -18,7 +18,7 @@ if NET_VENDOR_CHELSIO
 
 config CHELSIO_T1
 	tristate "Chelsio 10Gb Ethernet support"
-	depends on PCI
+	depends on PCI && ANCIENT_NETDEVICES
 	select CRC32
 	select MDIO
 	---help---
diff --git a/drivers/net/ethernet/chelsio/Makefile b/drivers/net/ethernet/chelsio/Makefile
index 390510b..10a8f92 100644
--- a/drivers/net/ethernet/chelsio/Makefile
+++ b/drivers/net/ethernet/chelsio/Makefile
@@ -2,7 +2,7 @@
 # Makefile for the Chelsio network device drivers.
 #
 
-obj-$(CONFIG_CHELSIO_T1) += cxgb/
+obj-y += ancient/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
 obj-$(CONFIG_CHELSIO_T4) += cxgb4/
 obj-$(CONFIG_CHELSIO_T4VF) += cxgb4vf/
diff --git a/drivers/net/ethernet/chelsio/ancient/Makefile b/drivers/net/ethernet/chelsio/ancient/Makefile
new file mode 100644
index 0000000..f60dbde
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/ancient/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_CHELSIO_T1) += cxgb/
diff --git a/drivers/net/ethernet/chelsio/cxgb/Makefile b/drivers/net/ethernet/chelsio/ancient/cxgb/Makefile
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/Makefile
rename to drivers/net/ethernet/chelsio/ancient/cxgb/Makefile
diff --git a/drivers/net/ethernet/chelsio/cxgb/common.h b/drivers/net/ethernet/chelsio/ancient/cxgb/common.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/common.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/common.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/cphy.h b/drivers/net/ethernet/chelsio/ancient/cxgb/cphy.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/cphy.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/cphy.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h b/drivers/net/ethernet/chelsio/ancient/cxgb/cpl5_cmd.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/cpl5_cmd.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/ancient/cxgb/cxgb2.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/cxgb2.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/cxgb2.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/elmer0.h b/drivers/net/ethernet/chelsio/ancient/cxgb/elmer0.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/elmer0.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/elmer0.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/espi.c b/drivers/net/ethernet/chelsio/ancient/cxgb/espi.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/espi.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/espi.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/espi.h b/drivers/net/ethernet/chelsio/ancient/cxgb/espi.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/espi.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/espi.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/fpga_defs.h b/drivers/net/ethernet/chelsio/ancient/cxgb/fpga_defs.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/fpga_defs.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/fpga_defs.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/gmac.h b/drivers/net/ethernet/chelsio/ancient/cxgb/gmac.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/gmac.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/gmac.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c b/drivers/net/ethernet/chelsio/ancient/cxgb/mv88e1xxx.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/mv88e1xxx.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.h b/drivers/net/ethernet/chelsio/ancient/cxgb/mv88e1xxx.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/mv88e1xxx.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c b/drivers/net/ethernet/chelsio/ancient/cxgb/mv88x201x.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/mv88x201x.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/my3126.c b/drivers/net/ethernet/chelsio/ancient/cxgb/my3126.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/my3126.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/my3126.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/pm3393.c b/drivers/net/ethernet/chelsio/ancient/cxgb/pm3393.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/pm3393.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/pm3393.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/regs.h b/drivers/net/ethernet/chelsio/ancient/cxgb/regs.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/regs.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/regs.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/ancient/cxgb/sge.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/sge.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/sge.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.h b/drivers/net/ethernet/chelsio/ancient/cxgb/sge.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/sge.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/sge.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/subr.c b/drivers/net/ethernet/chelsio/ancient/cxgb/subr.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/subr.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/subr.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h b/drivers/net/ethernet/chelsio/ancient/cxgb/suni1x10gexp_regs.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/suni1x10gexp_regs.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/tp.c b/drivers/net/ethernet/chelsio/ancient/cxgb/tp.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/tp.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/tp.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/tp.h b/drivers/net/ethernet/chelsio/ancient/cxgb/tp.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/tp.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/tp.h
diff --git a/drivers/net/ethernet/chelsio/cxgb/vsc7326.c b/drivers/net/ethernet/chelsio/ancient/cxgb/vsc7326.c
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/vsc7326.c
rename to drivers/net/ethernet/chelsio/ancient/cxgb/vsc7326.c
diff --git a/drivers/net/ethernet/chelsio/cxgb/vsc7326_reg.h b/drivers/net/ethernet/chelsio/ancient/cxgb/vsc7326_reg.h
similarity index 100%
rename from drivers/net/ethernet/chelsio/cxgb/vsc7326_reg.h
rename to drivers/net/ethernet/chelsio/ancient/cxgb/vsc7326_reg.h
-- 
2.6.3.368.gf34be46
