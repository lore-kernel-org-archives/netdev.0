From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH][TRIVIAL] drivers/net: endif comment fixes
Date: Sat, 4 Nov 2006 20:58:32 +0100
Message-ID: <20061104205832.51caff06@lucky.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Drebes <lists-receive@programmierforen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ensim03.ffm.m2soft.com ([195.38.20.12]:53483 "EHLO
	ensim03.ffm.m2soft.com") by vger.kernel.org with ESMTP
	id S965588AbWKDUAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Nov 2006 15:00:23 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

endif comments should match their corresponding if(n)defs.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---

 drivers/net/gianfar_mii.h                 |    2 +-
 drivers/net/sk98lin/h/skgei2c.h           |    2 +-
 drivers/net/sk98lin/h/ski2c.h             |    2 +-
 drivers/net/skfp/h/targetos.h             |    2 +-
 drivers/net/slip.h                        |    2 +-
 drivers/net/wireless/prism54/islpci_eth.h |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff -uprN a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
--- a/drivers/net/gianfar_mii.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/gianfar_mii.h	2006-11-04 20:32:43.000000000 +0100
@@ -43,4 +43,4 @@ int gfar_mdio_read(struct mii_bus *bus, 
 int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
 int __init gfar_mdio_init(void);
 void __exit gfar_mdio_exit(void);
-#endif /* GIANFAR_PHY_H */
+#endif /* __GIANFAR_MII_H */
diff -uprN a/drivers/net/sk98lin/h/skgei2c.h b/drivers/net/sk98lin/h/skgei2c.h
--- a/drivers/net/sk98lin/h/skgei2c.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/sk98lin/h/skgei2c.h	2006-11-04 20:35:22.000000000 +0100
@@ -207,4 +207,4 @@
 #define	SK_SEN_DYN_INIT_VAUX		11  /* Init VAUX with new thresholds */
 
 extern	int SkLm80ReadSensor(SK_AC *pAC, SK_IOC IoC, SK_SENSOR *pSen);
-#endif	/* n_INC_SKGEI2C_H */
+#endif	/* _INC_SKGEI2C_H_ */
diff -uprN a/drivers/net/sk98lin/h/ski2c.h b/drivers/net/sk98lin/h/ski2c.h
--- a/drivers/net/sk98lin/h/ski2c.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/sk98lin/h/ski2c.h	2006-11-04 20:34:16.000000000 +0100
@@ -170,5 +170,5 @@ extern int SkI2cEvent(SK_AC *pAC, SK_IOC
 extern void SkI2cWaitIrq(SK_AC *pAC, SK_IOC IoC);
 extern void SkI2cIsr(SK_AC *pAC, SK_IOC IoC);
 #endif /* !SK_DIAG */
-#endif /* n_SKI2C_H */
+#endif /* _SKI2C_H_ */
 
diff -uprN a/drivers/net/skfp/h/targetos.h b/drivers/net/skfp/h/targetos.h
--- a/drivers/net/skfp/h/targetos.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/skfp/h/targetos.h	2006-11-04 20:32:15.000000000 +0100
@@ -162,4 +162,4 @@ struct s_smt_os {
 
 typedef struct s_smt_os skfddi_priv;
 
-#endif	 // _TARGETOS_
+#endif	 // _TARGETOS_H
diff -uprN a/drivers/net/slip.h b/drivers/net/slip.h
--- a/drivers/net/slip.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/slip.h	2006-11-04 20:36:08.000000000 +0100
@@ -117,4 +117,4 @@ struct slip {
 
 #define SLIP_MAGIC 0x5302
 
-#endif	/* _LINUX_SLIP.H */
+#endif	/* _LINUX_SLIP_H */
diff -uprN a/drivers/net/wireless/prism54/islpci_eth.h b/drivers/net/wireless/prism54/islpci_eth.h
--- a/drivers/net/wireless/prism54/islpci_eth.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/wireless/prism54/islpci_eth.h	2006-11-04 20:37:20.000000000 +0100
@@ -70,4 +70,4 @@ int islpci_eth_receive(islpci_private *)
 void islpci_eth_tx_timeout(struct net_device *);
 void islpci_do_reset_and_wake(void *data);
 
-#endif				/* _ISL_GEN_H */
+#endif				/* _ISLPCI_ETH_H */

