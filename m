From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: [PATCH net-next 1/2] bna: QLogic BR-series Adapters Driver Rebranding
Date: Fri, 13 Feb 2015 17:06:05 -0500
Message-ID: <1423865166-13469-2-git-send-email-rasesh.mody@qlogic.com>
References: <1423865166-13469-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:56023 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752758AbbBMWpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 17:45:31 -0500
In-Reply-To: <1423865166-13469-1-git-send-email-rasesh.mody@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rasesh Mody <rasesh.mody@qlogic.com>
---
 drivers/net/ethernet/brocade/Kconfig                 |  8 ++++----
 drivers/net/ethernet/brocade/Makefile                |  2 +-
 drivers/net/ethernet/brocade/bna/Kconfig             | 12 ++++++------
 drivers/net/ethernet/brocade/bna/Makefile            |  3 ++-
 drivers/net/ethernet/brocade/bna/bfa_cee.c           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_cee.h           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_cs.h            |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs.h          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h      |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_defs_status.h   |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c           |  9 +++++----
 drivers/net/ethernet/brocade/bna/bfa_ioc.h           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c        |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_msgq.c          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfa_msgq.h          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi.h               |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi_cna.h           |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi_enet.h          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bfi_reg.h           | 13 +++++++------
 drivers/net/ethernet/brocade/bna/bna.h               |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_enet.c          |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h       |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c         |  7 ++++---
 drivers/net/ethernet/brocade/bna/bna_types.h         |  7 ++++---
 drivers/net/ethernet/brocade/bna/bnad.c              | 11 ++++++-----
 drivers/net/ethernet/brocade/bna/bnad.h              |  7 ++++---
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c      |  7 ++++---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c      |  7 ++++---
 drivers/net/ethernet/brocade/bna/cna.h               |  7 ++++---
 drivers/net/ethernet/brocade/bna/cna_fwimg.c         |  7 ++++---
 31 files changed, 127 insertions(+), 99 deletions(-)

diff --git a/drivers/net/ethernet/brocade/Kconfig b/drivers/net/ethernet/brocade/Kconfig
index 2641557..4e8c0b6 100644
--- a/drivers/net/ethernet/brocade/Kconfig
+++ b/drivers/net/ethernet/brocade/Kconfig
@@ -1,9 +1,9 @@
 #
-# Brocade device configuration
+# QLogic BR-series device configuration
 #
 
 config NET_VENDOR_BROCADE
-	bool "Brocade devices"
+	bool "QLogic BR-series devices"
 	default y
 	depends on PCI
 	---help---
@@ -13,8 +13,8 @@ config NET_VENDOR_BROCADE
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
-	  the questions about Brocade cards. If you say Y, you will be asked for
-	  your specific card in the following questions.
+	  the questions about QLogic BR-series cards. If you say Y, you will be
+	  asked for your specific card in the following questions.
 
 if NET_VENDOR_BROCADE
 
diff --git a/drivers/net/ethernet/brocade/Makefile b/drivers/net/ethernet/brocade/Makefile
index b58238d..fec10f9 100644
--- a/drivers/net/ethernet/brocade/Makefile
+++ b/drivers/net/ethernet/brocade/Makefile
@@ -1,5 +1,5 @@
 #
-# Makefile for the Brocade device drivers.
+# Makefile for the QLogic BR-series device drivers.
 #
 
 obj-$(CONFIG_BNA) += bna/
diff --git a/drivers/net/ethernet/brocade/bna/Kconfig b/drivers/net/ethernet/brocade/bna/Kconfig
index dc2eb52..fe01279 100644
--- a/drivers/net/ethernet/brocade/bna/Kconfig
+++ b/drivers/net/ethernet/brocade/bna/Kconfig
@@ -1,17 +1,17 @@
 #
-# Brocade network device configuration
+# QLogic BR-series network device configuration
 #
 
 config BNA
-	tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
+	tristate "QLogic BR-series 1010/1020/1860 10Gb Ethernet Driver support"
 	depends on PCI
 	---help---
-	  This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
-	  cards.
+	  This driver supports QLogic BR-series 1010/1020/1860 10Gb CEE capable
+	  Ethernet cards.
 	  To compile this driver as a module, choose M here: the module
 	  will be called bna.
 
-	  For general information and support, go to the Brocade support
+	  For general information and support, go to the QLogic support
 	  website at:
 
-	  <http://support.brocade.com>
+	  <http://support.qlogic.com>
diff --git a/drivers/net/ethernet/brocade/bna/Makefile b/drivers/net/ethernet/brocade/bna/Makefile
index 951339b..314a304 100644
--- a/drivers/net/ethernet/brocade/bna/Makefile
+++ b/drivers/net/ethernet/brocade/bna/Makefile
@@ -1,5 +1,6 @@
 #
-# Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+# Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+# Copyright (c) 2014-2015 QLogic Corporation.
 # All rights reserved.
 #
 KERNEL_DIR := /usr/src/net-next-3.18.0-rc6
diff --git a/drivers/net/ethernet/brocade/bna/bfa_cee.c b/drivers/net/ethernet/brocade/bna/bfa_cee.c
index 550d252..cf9f395 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cee.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_cee.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #include "bfa_cee.h"
diff --git a/drivers/net/ethernet/brocade/bna/bfa_cee.h b/drivers/net/ethernet/brocade/bna/bfa_cee.h
index 93fde63..d04eef5 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cee.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_cee.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #ifndef __BFA_CEE_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfa_cs.h b/drivers/net/ethernet/brocade/bna/bfa_cs.h
index ad004a4..af25d8e 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_cs.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 /* BFA common services */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index b7d8127..3bfd9da 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #ifndef __BFA_DEFS_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
index b39c5f2..63e300f 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BFA_DEFS_CNA_H__
 #define __BFA_DEFS_CNA_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
index 7fb396f..7a45cd0 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BFA_DEFS_MFG_COMM_H__
 #define __BFA_DEFS_MFG_COMM_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_status.h b/drivers/net/ethernet/brocade/bna/bfa_defs_status.h
index ea9af9a..a43b560 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_status.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_status.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BFA_DEFS_STATUS_H__
 #define __BFA_DEFS_STATUS_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 354ae97..f2d1323 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #include "bfa_ioc.h"
@@ -2763,7 +2764,7 @@ bfa_nw_ioc_notify_register(struct bfa_ioc *ioc,
 	list_add_tail(&notify->qe, &ioc->notify_q);
 }
 
-#define BFA_MFG_NAME "Brocade"
+#define BFA_MFG_NAME "QLogic"
 static void
 bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
 			 struct bfa_adapter_attr *ad_attr)
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index 20cff7d..effb715 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #ifndef __BFA_IOC_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index d639558..66c8507 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #include "bfa_ioc.h"
diff --git a/drivers/net/ethernet/brocade/bna/bfa_msgq.c b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
index 55067d0..c07d5b9 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_msgq.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 /* MSGQ module source file. */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_msgq.h b/drivers/net/ethernet/brocade/bna/bfa_msgq.h
index a6a565a..66bc8b5 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_msgq.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_msgq.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #ifndef __BFA_MSGQ_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index 8c563a7..f1e1129 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BFI_H__
 #define __BFI_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfi_cna.h b/drivers/net/ethernet/brocade/bna/bfi_cna.h
index 6704a43..bd605be 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_cna.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BFI_CNA_H__
 #define __BFI_CNA_H__
diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
index ae072dc..bccca3b 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 /* BNA Hardware and Firmware Interface */
diff --git a/drivers/net/ethernet/brocade/bna/bfi_reg.h b/drivers/net/ethernet/brocade/bna/bfi_reg.h
index c49fa31..2835b51 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_reg.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_reg.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,13 +11,14 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 /*
- * bfi_reg.h ASIC register defines for all Brocade adapter ASICs
+ * bfi_reg.h ASIC register defines for all QLogic BR-series adapter ASICs
  */
 
 #ifndef __BFI_REG_H__
@@ -221,7 +222,7 @@ enum {
 #define __PMM_1T_RESET_P		0x00000001
 #define PMM_1T_RESET_REG_P1		0x00023c1c
 
-/* Brocade 1860 Adapter specific defines */
+/* QLogic BR-series 1860 Adapter specific defines */
 #define CT2_PCI_CPQ_BASE		0x00030000
 #define CT2_PCI_APP_BASE		0x00030100
 #define CT2_PCI_ETH_BASE		0x00030400
@@ -264,7 +265,7 @@ enum {
 #define CT2_HOSTFN_MSIX_VT_INDEX_MBOX_ERR	(CT2_PCI_APP_BASE + 0x38)
 
 /*
- * Brocade 1860 adapter CPQ block registers
+ * QLogic BR-series 1860 adapter CPQ block registers
  */
 #define CT2_HOSTFN_LPU0_MBOX0		(CT2_PCI_CPQ_BASE + 0x00)
 #define CT2_HOSTFN_LPU1_MBOX0		(CT2_PCI_CPQ_BASE + 0x20)
diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 1f51219..8ba72b1 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BNA_H__
 #define __BNA_H__
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 903466e..deb8da6 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #include "bna.h"
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
index 2702d02..c5feab1 100644
--- a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 /* File for interrupt macros and functions */
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 5fac411..8ab3a5f 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
   */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #include "bna.h"
 #include "bfi.h"
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index 621547c..d0a7a56 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BNA_TYPES_H__
 #define __BNA_TYPES_H__
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 3237218..29be1af 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #include <linux/bitops.h>
 #include <linux/netdevice.h>
@@ -3867,7 +3868,7 @@ bnad_module_init(void)
 {
 	int err;
 
-	pr_info("Brocade 10G Ethernet driver - version: %s\n",
+	pr_info("QLogic BR-series 10G Ethernet driver - version: %s\n",
 			BNAD_VERSION);
 
 	bfa_nw_ioc_auto_recover(bnad_ioc_auto_recover);
@@ -3894,7 +3895,7 @@ module_exit(bnad_module_exit);
 
 MODULE_AUTHOR("Brocade");
 MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Brocade 10G PCIe Ethernet driver");
+MODULE_DESCRIPTION("QLogic BR-series 10G PCIe Ethernet driver");
 MODULE_VERSION(BNAD_VERSION);
 MODULE_FIRMWARE(CNA_FW_FILE_CT);
 MODULE_FIRMWARE(CNA_FW_FILE_CT2);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 2842c18..e6c285c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #ifndef __BNAD_H__
 #define __BNAD_H__
diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index 7d6aa8c..d25c87c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #include <linux/debugfs.h>
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index d26adac..12f344d 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #include "cna.h"
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index b3ff6d5..3be5d98 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2006-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2006-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 
 #ifndef __CNA_H__
diff --git a/drivers/net/ethernet/brocade/bna/cna_fwimg.c b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
index 6f72771..ebf462d 100644
--- a/drivers/net/ethernet/brocade/bna/cna_fwimg.c
+++ b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
@@ -1,5 +1,5 @@
 /*
- * Linux network driver for Brocade Converged Network Adapter.
+ * Linux network driver for QLogic BR-series Converged Network Adapter.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License (GPL) Version 2 as
@@ -11,9 +11,10 @@
  * General Public License for more details.
  */
 /*
- * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
+ * Copyright (c) 2005-2014 Brocade Communications Systems, Inc.
+ * Copyright (c) 2014-2015 QLogic Corporation
  * All rights reserved
- * www.brocade.com
+ * www.qlogic.com
  */
 #include <linux/firmware.h>
 #include "bnad.h"
-- 
1.8.2.3
