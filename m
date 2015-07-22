From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/6] bnx2x: Rebrand from 'broadcom' into 'qlogic'
Date: Wed, 22 Jul 2015 09:16:23 +0300
Message-ID: <1437545787-22097-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:51340 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753838AbbGVGRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:17:04 -0400
In-Reply-To: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x still appears as a Broadcom driver even though the devices it
utilizes belong to Qlogic for more than a year.

This patch changes the various headers and the device strings to indica=
te
the correct ownership of the device.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    | 10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h    | 10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h   | 10 +++--
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  4 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |  4 +-
 .../ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h    |  2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h   |  4 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h   |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   | 10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   | 10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 50 +++++++++++---=
--------
 .../net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h    |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     | 14 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     | 14 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  | 10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h  | 10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h  |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c   | 10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h   | 22 ++++++----
 25 files changed, 142 insertions(+), 88 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/=
ethernet/broadcom/bnx2x/bnx2x.h
index cd4ae76..a59f0b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1,6 +1,8 @@
-/* bnx2x.h: Broadcom Everest network driver.
+/* bnx2x.h: QLogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index fc32821..e395ae9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1,6 +1,8 @@
-/* bnx2x_cmn.c: Broadcom Everest network driver.
+/* bnx2x_cmn.c: QLogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index ec50d12..77693d3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1,6 +1,8 @@
-/* bnx2x_cmn.h: Broadcom Everest network driver.
+/* bnx2x_cmn.h: QLogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index b50f154..7ccf668 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -1,15 +1,17 @@
-/* bnx2x_dcb.c: Broadcom Everest network driver.
+/* bnx2x_dcb.c: QLogic Everest network driver.
  *
  * Copyright 2009-2013 Broadcom Corporation
+ * Copyright 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
  * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other QLogic software provided under a
+ * license other than the GPL, without QLogic's express prior written
  * consent.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
index c6939ec..9a9517c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
@@ -1,15 +1,17 @@
-/* bnx2x_dcb.h: Broadcom Everest network driver.
+/* bnx2x_dcb.h: QLogic Everest network driver.
  *
  * Copyright 2009-2013 Broadcom Corporation
+ * Copyright 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
  * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other QLogic software provided under a
+ * license other than the GPL, without QLogic's express prior written
  * consent.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
index 741aa13..eccfa13 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
@@ -1,15 +1,17 @@
-/* bnx2x_dump.h: Broadcom Everest network driver.
+/* bnx2x_dump.h: QLogic Everest network driver.
  *
  * Copyright (c) 2012-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
  * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other QLogic software provided under a
+ * license other than the GPL, without QLogic's express prior written
  * consent.
  */
=20
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/driv=
ers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 76b9052..93c78a8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1,6 +1,8 @@
-/* bnx2x_ethtool.c: Broadcom Everest network driver.
+/* bnx2x_ethtool.c: QLogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/driv=
ers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index bfda526..226ab29 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -1,6 +1,8 @@
-/* bnx2x_fw_defs.h: Broadcom Everest network driver.
+/* bnx2x_fw_defs.h: Qlogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h b/=
drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
index 8aafd9b..9e3b5a1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
@@ -1,6 +1,8 @@
 /* bnx2x_fw_file_hdr.h: FW binary file header structure.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 2b6f97b..a838b6e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1,6 +1,8 @@
-/* bnx2x_hsi.h: Broadcom Everest network driver.
+/* bnx2x_hsi.h: Qlogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_init.h
index d6e1975..46ee2c0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
@@ -1,7 +1,9 @@
-/* bnx2x_init.h: Broadcom Everest network driver.
+/* bnx2x_init.h: Qlogic Everest network driver.
  *               Structures and macroes needed during the initializati=
on.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/dri=
vers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index 5669ed2..1835d2e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -1,8 +1,10 @@
-/* bnx2x_init_ops.h: Broadcom Everest network driver.
+/* bnx2x_init_ops.h: Qlogic Everest network driver.
  *               Static functions needed during the initialization.
  *               This file is "included" in bnx2x_main.c.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index a0b03c2..7f9ec51 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -1,13 +1,15 @@
 /* Copyright 2008-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
- * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
+ * at http://www.gnu.org/licenses/gpl-2.0.html (the "GPL").
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other Qlogic software provided under a
+ * license other than the GPL, without Qlogic's express prior written
  * consent.
  *
  * Written by Yaniv Rosner
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index d9cce4c..b7d2511 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -1,13 +1,15 @@
 /* Copyright 2008-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
- * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
+ * at http://www.gnu.org/licenses/gpl-2.0.html (the "GPL").
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other Qlogic software provided under a
+ * license other than the GPL, without Qlogic's express prior written
  * consent.
  *
  * Written by Yaniv Rosner
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 845471b..e85e6ff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1,6 +1,8 @@
-/* bnx2x_main.c: Broadcom Everest network driver.
+/* bnx2x_main.c: QLogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
@@ -81,11 +83,11 @@
 #define TX_TIMEOUT		(5*HZ)
=20
 static char version[] =3D
-	"Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver "
+	"QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
=20
 MODULE_AUTHOR("Eliezer Tamir");
-MODULE_DESCRIPTION("Broadcom NetXtreme II "
+MODULE_DESCRIPTION("QLogic "
 		   "BCM57710/57711/57711E/"
 		   "57712/57712_MF/57800/57800_MF/57810/57810_MF/"
 		   "57840/57840_MF Driver");
@@ -163,27 +165,27 @@ enum bnx2x_board_type {
 static struct {
 	char *name;
 } board_info[] =3D {
-	[BCM57710]	=3D { "Broadcom NetXtreme II BCM57710 10 Gigabit PCIe [Eve=
rest]" },
-	[BCM57711]	=3D { "Broadcom NetXtreme II BCM57711 10 Gigabit PCIe" },
-	[BCM57711E]	=3D { "Broadcom NetXtreme II BCM57711E 10 Gigabit PCIe" }=
,
-	[BCM57712]	=3D { "Broadcom NetXtreme II BCM57712 10 Gigabit Ethernet"=
 },
-	[BCM57712_MF]	=3D { "Broadcom NetXtreme II BCM57712 10 Gigabit Ethern=
et Multi Function" },
-	[BCM57712_VF]	=3D { "Broadcom NetXtreme II BCM57712 10 Gigabit Ethern=
et Virtual Function" },
-	[BCM57800]	=3D { "Broadcom NetXtreme II BCM57800 10 Gigabit Ethernet"=
 },
-	[BCM57800_MF]	=3D { "Broadcom NetXtreme II BCM57800 10 Gigabit Ethern=
et Multi Function" },
-	[BCM57800_VF]	=3D { "Broadcom NetXtreme II BCM57800 10 Gigabit Ethern=
et Virtual Function" },
-	[BCM57810]	=3D { "Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet"=
 },
-	[BCM57810_MF]	=3D { "Broadcom NetXtreme II BCM57810 10 Gigabit Ethern=
et Multi Function" },
-	[BCM57810_VF]	=3D { "Broadcom NetXtreme II BCM57810 10 Gigabit Ethern=
et Virtual Function" },
-	[BCM57840_4_10]	=3D { "Broadcom NetXtreme II BCM57840 10 Gigabit Ethe=
rnet" },
-	[BCM57840_2_20]	=3D { "Broadcom NetXtreme II BCM57840 20 Gigabit Ethe=
rnet" },
-	[BCM57840_MF]	=3D { "Broadcom NetXtreme II BCM57840 10/20 Gigabit Eth=
ernet Multi Function" },
-	[BCM57840_VF]	=3D { "Broadcom NetXtreme II BCM57840 10/20 Gigabit Eth=
ernet Virtual Function" },
-	[BCM57811]	=3D { "Broadcom NetXtreme II BCM57811 10 Gigabit Ethernet"=
 },
-	[BCM57811_MF]	=3D { "Broadcom NetXtreme II BCM57811 10 Gigabit Ethern=
et Multi Function" },
-	[BCM57840_O]	=3D { "Broadcom NetXtreme II BCM57840 10/20 Gigabit Ethe=
rnet" },
-	[BCM57840_MFO]	=3D { "Broadcom NetXtreme II BCM57840 10/20 Gigabit Et=
hernet Multi Function" },
-	[BCM57811_VF]	=3D { "Broadcom NetXtreme II BCM57840 10/20 Gigabit Eth=
ernet Virtual Function" }
+	[BCM57710]	=3D { "QLogic BCM57710 10 Gigabit PCIe [Everest]" },
+	[BCM57711]	=3D { "QLogic BCM57711 10 Gigabit PCIe" },
+	[BCM57711E]	=3D { "QLogic BCM57711E 10 Gigabit PCIe" },
+	[BCM57712]	=3D { "QLogic BCM57712 10 Gigabit Ethernet" },
+	[BCM57712_MF]	=3D { "QLogic BCM57712 10 Gigabit Ethernet Multi Functi=
on" },
+	[BCM57712_VF]	=3D { "QLogic BCM57712 10 Gigabit Ethernet Virtual Func=
tion" },
+	[BCM57800]	=3D { "QLogic BCM57800 10 Gigabit Ethernet" },
+	[BCM57800_MF]	=3D { "QLogic BCM57800 10 Gigabit Ethernet Multi Functi=
on" },
+	[BCM57800_VF]	=3D { "QLogic BCM57800 10 Gigabit Ethernet Virtual Func=
tion" },
+	[BCM57810]	=3D { "QLogic BCM57810 10 Gigabit Ethernet" },
+	[BCM57810_MF]	=3D { "QLogic BCM57810 10 Gigabit Ethernet Multi Functi=
on" },
+	[BCM57810_VF]	=3D { "QLogic BCM57810 10 Gigabit Ethernet Virtual Func=
tion" },
+	[BCM57840_4_10]	=3D { "QLogic BCM57840 10 Gigabit Ethernet" },
+	[BCM57840_2_20]	=3D { "QLogic BCM57840 20 Gigabit Ethernet" },
+	[BCM57840_MF]	=3D { "QLogic BCM57840 10/20 Gigabit Ethernet Multi Fun=
ction" },
+	[BCM57840_VF]	=3D { "QLogic BCM57840 10/20 Gigabit Ethernet Virtual F=
unction" },
+	[BCM57811]	=3D { "QLogic BCM57811 10 Gigabit Ethernet" },
+	[BCM57811_MF]	=3D { "QLogic BCM57811 10 Gigabit Ethernet Multi Functi=
on" },
+	[BCM57840_O]	=3D { "QLogic BCM57840 10/20 Gigabit Ethernet" },
+	[BCM57840_MFO]	=3D { "QLogic BCM57840 10/20 Gigabit Ethernet Multi Fu=
nction" },
+	[BCM57811_VF]	=3D { "QLogic BCM57840 10/20 Gigabit Ethernet Virtual F=
unction" }
 };
=20
 #ifndef PCI_DEVICE_ID_NX2_57710
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h b/driv=
ers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
index caf1aef..a91ccbf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
@@ -1,6 +1,8 @@
-/* bnx2x_mfw_req.h: Broadcom Everest network driver.
+/* bnx2x_mfw_req.h: Qlogic Everest network driver.
  *
  * Copyright (c) 2012-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 49d5110..b7d33a1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1,6 +1,8 @@
-/* bnx2x_reg.h: Broadcom Everest network driver.
+/* bnx2x_reg.h: Qlogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/n=
et/ethernet/broadcom/bnx2x/bnx2x_sp.c
index c55f780..0d7468e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -1,15 +1,17 @@
-/* bnx2x_sp.c: Broadcom Everest network driver.
+/* bnx2x_sp.c: Qlogic Everest network driver.
  *
- * Copyright (c) 2011-2013 Broadcom Corporation
+ * Copyright 2011-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and Qlogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
- * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
+ * at http://www.gnu.org/licenses/gpl-2.0.html (the "GPL").
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other Qlogic software provided under a
+ * license other than the GPL, without Qlogic's express prior written
  * consent.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/n=
et/ethernet/broadcom/bnx2x/bnx2x_sp.h
index df27bb8..324e9f9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -1,15 +1,17 @@
-/* bnx2x_sp.h: Broadcom Everest network driver.
+/* bnx2x_sp.h: Qlogic Everest network driver.
  *
- * Copyright (c) 2011-2013 Broadcom Corporation
+ * Copyright 2011-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and Qlogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
- * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
+ * at http://www.gnu.org/licenses/gpl-2.0.html (the "GPL").
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other Qlogic software provided under a
+ * license other than the GPL, without Qlogic's express prior written
  * consent.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index f67348d..4d5c7b3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1,15 +1,17 @@
-/* bnx2x_sriov.c: Broadcom Everest network driver.
+/* bnx2x_sriov.c: QLogic Everest network driver.
  *
  * Copyright 2009-2013 Broadcom Corporation
+ * Copyright 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
  * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other QLogic software provided under a
+ * license other than the GPL, without QLogic's express prior written
  * consent.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 66ee62a..2011205 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -1,15 +1,17 @@
-/* bnx2x_sriov.h: Broadcom Everest network driver.
+/* bnx2x_sriov.h: QLogic Everest network driver.
  *
  * Copyright 2009-2013 Broadcom Corporation
+ * Copyright 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
  * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other QLogic software provided under a
+ * license other than the GPL, without QLogic's express prior written
  * consent.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 69d699f0..7e0919a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1,6 +1,8 @@
-/* bnx2x_stats.c: Broadcom Everest network driver.
+/* bnx2x_stats.c: QLogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 965539a..b2644ed 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -1,6 +1,8 @@
-/* bnx2x_stats.h: Broadcom Everest network driver.
+/* bnx2x_stats.h: QLogic Everest network driver.
  *
  * Copyright (c) 2007-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
  * This program is free software; you can redistribute it and/or modif=
y
  * it under the terms of the GNU General Public License as published b=
y
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 06b8c0d..31b79bd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1,15 +1,17 @@
-/* bnx2x_vfpf.c: Broadcom Everest network driver.
+/* bnx2x_vfpf.c: QLogic Everest network driver.
  *
  * Copyright 2009-2013 Broadcom Corporation
+ * Copyright 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and QLogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
  * under the terms of the GNU General Public License version 2, availa=
ble
  * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
  *
  * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
+ * software in any way with any other QLogic software provided under a
+ * license other than the GPL, without QLogic's express prior written
  * consent.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index b86479f..f0110f4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -1,16 +1,22 @@
-/* bnx2x_vfpf.h: Broadcom Everest network driver.
+/* bnx2x_vfpf.h: Qlogic Everest network driver.
  *
  * Copyright (c) 2011-2013 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
+ * All rights reserved
  *
- * Unless you and Broadcom execute a separate written software license
+ * Unless you and Qlogic execute a separate written software license
  * agreement governing use of this software, this software is licensed=
 to you
- * under the terms of the GNU General Public License version 2, availa=
ble
- * at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html (the "GPL"=
).
+ * under the terms of the GNU General Public License version 2 (the =E2=
=80=9CGPL=E2=80=9D),
+ * available at http://www.gnu.org/licenses/gpl-2.0.html, with the fol=
lowing
+ * added to such license:
  *
- * Notwithstanding the above, under no circumstances may you combine t=
his
- * software in any way with any other Broadcom software provided under=
 a
- * license other than the GPL, without Broadcom's express prior writte=
n
- * consent.
+ * As a special exception, the copyright holders of this software give=
 you
+ * permission to link this software with independent modules, and to c=
opy and
+ * distribute the resulting executable under terms of your choice, pro=
vided that
+ * you also meet, for each linked independent module, the terms and co=
nditions
+ * of the license of that module.  An independent module is a module w=
hich is
+ * not derived from this software.  The special exception does not app=
ly to any
+ * modifications of the software.
  *
  * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Ariel Elior <ariel.elior@qlogic.com>
--=20
1.9.3
