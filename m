From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/10] ibm/emac: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:09:55 -0700
Message-ID: <d4cb2ee17dbb9fb636e5e127e8cb6cbde9d28cef.1380056108.git.joe@perches.com>
References: <cover.1380056108.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380056108.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/ibm/emac/debug.h | 14 +++++++-------
 drivers/net/ethernet/ibm/emac/rgmii.h | 18 +++++++++---------
 drivers/net/ethernet/ibm/emac/tah.h   | 14 +++++++-------
 drivers/net/ethernet/ibm/emac/zmii.h  | 18 +++++++++---------
 4 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/debug.h b/drivers/net/ethernet/ibm/emac/debug.h
index 59a92d5..9c45efe 100644
--- a/drivers/net/ethernet/ibm/emac/debug.h
+++ b/drivers/net/ethernet/ibm/emac/debug.h
@@ -29,13 +29,13 @@
 struct emac_instance;
 struct mal_instance;
 
-extern void emac_dbg_register(struct emac_instance *dev);
-extern void emac_dbg_unregister(struct emac_instance *dev);
-extern void mal_dbg_register(struct mal_instance *mal);
-extern void mal_dbg_unregister(struct mal_instance *mal);
-extern int emac_init_debug(void) __init;
-extern void emac_fini_debug(void) __exit;
-extern void emac_dbg_dump_all(void);
+void emac_dbg_register(struct emac_instance *dev);
+void emac_dbg_unregister(struct emac_instance *dev);
+void mal_dbg_register(struct mal_instance *mal);
+void mal_dbg_unregister(struct mal_instance *mal);
+int emac_init_debug(void) __init;
+void emac_fini_debug(void) __exit;
+void emac_dbg_dump_all(void);
 
 # define DBG_LEVEL		1
 
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.h b/drivers/net/ethernet/ibm/emac/rgmii.h
index 668bcee..d4f1374 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.h
+++ b/drivers/net/ethernet/ibm/emac/rgmii.h
@@ -56,15 +56,15 @@ struct rgmii_instance {
 
 #ifdef CONFIG_IBM_EMAC_RGMII
 
-extern int rgmii_init(void);
-extern void rgmii_exit(void);
-extern int rgmii_attach(struct platform_device *ofdev, int input, int mode);
-extern void rgmii_detach(struct platform_device *ofdev, int input);
-extern void rgmii_get_mdio(struct platform_device *ofdev, int input);
-extern void rgmii_put_mdio(struct platform_device *ofdev, int input);
-extern void rgmii_set_speed(struct platform_device *ofdev, int input, int speed);
-extern int rgmii_get_regs_len(struct platform_device *ofdev);
-extern void *rgmii_dump_regs(struct platform_device *ofdev, void *buf);
+int rgmii_init(void);
+void rgmii_exit(void);
+int rgmii_attach(struct platform_device *ofdev, int input, int mode);
+void rgmii_detach(struct platform_device *ofdev, int input);
+void rgmii_get_mdio(struct platform_device *ofdev, int input);
+void rgmii_put_mdio(struct platform_device *ofdev, int input);
+void rgmii_set_speed(struct platform_device *ofdev, int input, int speed);
+int rgmii_get_regs_len(struct platform_device *ofdev);
+void *rgmii_dump_regs(struct platform_device *ofdev, void *buf);
 
 #else
 
diff --git a/drivers/net/ethernet/ibm/emac/tah.h b/drivers/net/ethernet/ibm/emac/tah.h
index 350b709..4d5f336 100644
--- a/drivers/net/ethernet/ibm/emac/tah.h
+++ b/drivers/net/ethernet/ibm/emac/tah.h
@@ -72,13 +72,13 @@ struct tah_instance {
 
 #ifdef CONFIG_IBM_EMAC_TAH
 
-extern int tah_init(void);
-extern void tah_exit(void);
-extern int tah_attach(struct platform_device *ofdev, int channel);
-extern void tah_detach(struct platform_device *ofdev, int channel);
-extern void tah_reset(struct platform_device *ofdev);
-extern int tah_get_regs_len(struct platform_device *ofdev);
-extern void *tah_dump_regs(struct platform_device *ofdev, void *buf);
+int tah_init(void);
+void tah_exit(void);
+int tah_attach(struct platform_device *ofdev, int channel);
+void tah_detach(struct platform_device *ofdev, int channel);
+void tah_reset(struct platform_device *ofdev);
+int tah_get_regs_len(struct platform_device *ofdev);
+void *tah_dump_regs(struct platform_device *ofdev, void *buf);
 
 #else
 
diff --git a/drivers/net/ethernet/ibm/emac/zmii.h b/drivers/net/ethernet/ibm/emac/zmii.h
index 455bfb0..0959c55 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.h
+++ b/drivers/net/ethernet/ibm/emac/zmii.h
@@ -53,15 +53,15 @@ struct zmii_instance {
 
 #ifdef CONFIG_IBM_EMAC_ZMII
 
-extern int zmii_init(void);
-extern void zmii_exit(void);
-extern int zmii_attach(struct platform_device *ofdev, int input, int *mode);
-extern void zmii_detach(struct platform_device *ofdev, int input);
-extern void zmii_get_mdio(struct platform_device *ofdev, int input);
-extern void zmii_put_mdio(struct platform_device *ofdev, int input);
-extern void zmii_set_speed(struct platform_device *ofdev, int input, int speed);
-extern int zmii_get_regs_len(struct platform_device *ocpdev);
-extern void *zmii_dump_regs(struct platform_device *ofdev, void *buf);
+int zmii_init(void);
+void zmii_exit(void);
+int zmii_attach(struct platform_device *ofdev, int input, int *mode);
+void zmii_detach(struct platform_device *ofdev, int input);
+void zmii_get_mdio(struct platform_device *ofdev, int input);
+void zmii_put_mdio(struct platform_device *ofdev, int input);
+void zmii_set_speed(struct platform_device *ofdev, int input, int speed);
+int zmii_get_regs_len(struct platform_device *ocpdev);
+void *zmii_dump_regs(struct platform_device *ofdev, void *buf);
 
 #else
 # define zmii_init()		0
-- 
1.8.1.2.459.gbcd45b4.dirty
