From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 3/8] <linux/phy.h>: coding style fixes
Date: Sun, 5 Jan 2014 03:20:17 +0300
Message-ID: <201401050320.17188.sergei.shtylyov@cogentembedded.com>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:63549 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854AbaADXUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:20:18 -0500
Received: by mail-la0-f48.google.com with SMTP id n7so8820911lam.7
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:20:16 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id h11sm39505094lbg.8.2014.01.04.15.20.15
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 15:20:16 -0800 (PST)
In-Reply-To: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running 'checkpatch.pl' gives some errors and warnings:

- no spaces around =;

- * separated by space from the function name;

- { in function definition not on a separate line;

- line over 80 characters.

While fixing these, also fix the following style issues:

- file name in the heading comment;

- alignment not matching open paren.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 2:
- new patch in this series.

 include/linux/phy.h |   38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

Index: net-next/include/linux/phy.h
===================================================================
--- net-next.orig/include/linux/phy.h
+++ net-next/include/linux/phy.h
@@ -1,6 +1,4 @@
 /*
- * include/linux/phy.h
- *
  * Framework and drivers for configuring and reading different PHYs
  * Based on code in sungem_phy.c and gianfar_phy.c
  *
@@ -240,7 +238,7 @@ int mdiobus_write(struct mii_bus *bus, i
  * - phy_stop moves to HALTED
  */
 enum phy_state {
-	PHY_DOWN=0,
+	PHY_DOWN = 0,
 	PHY_STARTING,
 	PHY_READY,
 	PHY_PENDING,
@@ -544,21 +542,22 @@ static inline bool phy_is_internal(struc
 }
 
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
-		bool is_c45, struct phy_c45_device_ids *c45_ids);
+				     bool is_c45,
+				     struct phy_c45_device_ids *c45_ids);
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
 int phy_device_register(struct phy_device *phy);
 int phy_init_hw(struct phy_device *phydev);
 int phy_suspend(struct phy_device *phydev);
 int phy_resume(struct phy_device *phydev);
-struct phy_device * phy_attach(struct net_device *dev,
-		const char *bus_id, phy_interface_t interface);
+struct phy_device *phy_attach(struct net_device *dev, const char *bus_id,
+			      phy_interface_t interface);
 struct phy_device *phy_find_first(struct mii_bus *bus);
 int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
-		void (*handler)(struct net_device *),
-		phy_interface_t interface);
-struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
-		void (*handler)(struct net_device *),
-		phy_interface_t interface);
+		       void (*handler)(struct net_device *),
+		       phy_interface_t interface);
+struct phy_device *phy_connect(struct net_device *dev, const char *bus_id,
+			       void (*handler)(struct net_device *),
+			       phy_interface_t interface);
 void phy_disconnect(struct phy_device *phydev);
 void phy_detach(struct phy_device *phydev);
 void phy_start(struct phy_device *phydev);
@@ -567,7 +566,8 @@ int phy_start_aneg(struct phy_device *ph
 
 int phy_stop_interrupts(struct phy_device *phydev);
 
-static inline int phy_read_status(struct phy_device *phydev) {
+static inline int phy_read_status(struct phy_device *phydev)
+{
 	return phydev->drv->read_status(phydev);
 }
 
@@ -586,22 +586,21 @@ void phy_state_machine(struct work_struc
 void phy_change(struct work_struct *work);
 void phy_mac_interrupt(struct phy_device *phydev, int new_link);
 void phy_start_machine(struct phy_device *phydev,
-		void (*handler)(struct net_device *));
+		       void (*handler)(struct net_device *));
 void phy_stop_machine(struct phy_device *phydev);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
-int phy_mii_ioctl(struct phy_device *phydev,
-		struct ifreq *ifr, int cmd);
+int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 void phy_device_free(struct phy_device *phydev);
 
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
-		int (*run)(struct phy_device *));
+		       int (*run)(struct phy_device *));
 int phy_register_fixup_for_id(const char *bus_id,
-		int (*run)(struct phy_device *));
+			      int (*run)(struct phy_device *));
 int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
-		int (*run)(struct phy_device *));
+			       int (*run)(struct phy_device *));
 int phy_scan_fixups(struct phy_device *phydev);
 
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
@@ -609,7 +608,8 @@ int phy_get_eee_err(struct phy_device *p
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data);
 int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data);
 int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
-void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
+void phy_ethtool_get_wol(struct phy_device *phydev,
+			 struct ethtool_wolinfo *wol);
 
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
