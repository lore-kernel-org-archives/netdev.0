From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] e1000e: Bump the version to 3.2.5
Date: Wed,  3 Jun 2015 04:27:56 -0700
Message-ID: <1433330876-2658-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41672 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754547AbbFCL2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:07 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

Bump the version to reflect the driver changes and bug fixes for i219.
Also update the copyright, while we are at it.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c | 2 +-
 drivers/net/ethernet/intel/e1000e/80003es2lan.h | 2 +-
 drivers/net/ethernet/intel/e1000e/82571.c       | 2 +-
 drivers/net/ethernet/intel/e1000e/82571.h       | 2 +-
 drivers/net/ethernet/intel/e1000e/defines.h     | 2 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       | 2 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c     | 2 +-
 drivers/net/ethernet/intel/e1000e/hw.h          | 2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c     | 2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.h     | 2 +-
 drivers/net/ethernet/intel/e1000e/mac.c         | 2 +-
 drivers/net/ethernet/intel/e1000e/mac.h         | 2 +-
 drivers/net/ethernet/intel/e1000e/manage.c      | 2 +-
 drivers/net/ethernet/intel/e1000e/manage.h      | 2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      | 6 +++---
 drivers/net/ethernet/intel/e1000e/nvm.c         | 2 +-
 drivers/net/ethernet/intel/e1000e/nvm.h         | 2 +-
 drivers/net/ethernet/intel/e1000e/param.c       | 2 +-
 drivers/net/ethernet/intel/e1000e/phy.c         | 2 +-
 drivers/net/ethernet/intel/e1000e/phy.h         | 2 +-
 drivers/net/ethernet/intel/e1000e/ptp.c         | 2 +-
 drivers/net/ethernet/intel/e1000e/regs.h        | 2 +-
 22 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 08f22f3..2af603f 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.h b/drivers/net/ethernet/intel/e1000e/80003es2lan.h
index 535a943..a2162e1 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.h
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 32e7775..5f70164 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/82571.h b/drivers/net/ethernet/intel/e1000e/82571.h
index 2e758f7..abc6a9a 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.h
+++ b/drivers/net/ethernet/intel/e1000e/82571.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 0570c66..133d407 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 7d8a45c..0b748d1 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index c62f0db..ad6daa6 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 19e8c48..c9da465 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index d9f7b93..b074b9a 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 193c445..2645985 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 30b74d5..e59d7c2 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/mac.h b/drivers/net/ethernet/intel/e1000e/mac.h
index 0513d90..8284618 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.h
+++ b/drivers/net/ethernet/intel/e1000e/mac.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index 06edfca..cc9b3be 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/manage.h b/drivers/net/ethernet/intel/e1000e/manage.h
index a8c27f9..0b9ea59 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.h
+++ b/drivers/net/ethernet/intel/e1000e/manage.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index b7035bc..e62b9dc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -48,7 +48,7 @@
 
 #define DRV_EXTRAVERSION "-k"
 
-#define DRV_VERSION "2.3.2" DRV_EXTRAVERSION
+#define DRV_VERSION "3.2.5" DRV_EXTRAVERSION
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
@@ -7438,7 +7438,7 @@ static int __init e1000_init_module(void)
 
 	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
 		e1000e_driver_version);
-	pr_info("Copyright(c) 1999 - 2014 Intel Corporation.\n");
+	pr_info("Copyright(c) 1999 - 2015 Intel Corporation.\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
index fa6b103..49f205c 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.h b/drivers/net/ethernet/intel/e1000e/nvm.h
index 342bf69..5d46967 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.h
+++ b/drivers/net/ethernet/intel/e1000e/nvm.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index aa1923f..6d8c39a 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index b2005e1..de13aea 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/phy.h b/drivers/net/ethernet/intel/e1000e/phy.h
index 537d278..55bfe47 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.h
+++ b/drivers/net/ethernet/intel/e1000e/phy.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 8d7b21d..25a0ad5 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/e1000e/regs.h b/drivers/net/ethernet/intel/e1000e/regs.h
index 110e27e..b24e5fe 100644
--- a/drivers/net/ethernet/intel/e1000e/regs.h
+++ b/drivers/net/ethernet/intel/e1000e/regs.h
@@ -1,5 +1,5 @@
 /* Intel PRO/1000 Linux driver
- * Copyright(c) 1999 - 2014 Intel Corporation.
+ * Copyright(c) 1999 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
-- 
2.1.0
