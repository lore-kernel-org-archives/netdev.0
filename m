From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 10/10] bnx2x: Introduce 2013 and advance
 version to 1.78.02
Date: Mon, 14 Jan 2013 17:11:50 +0200
Message-ID: <1358176310-31504-11-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3469 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757206Ab3ANQLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:11:32 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h             | 6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c         | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h         | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c         | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h         | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c     | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h     | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h         | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h        | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h    | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c        | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h        | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c        | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h     | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h         | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c          | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h          | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c       | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h       | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c       | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h       | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c        | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h        | 2 +-
 24 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 757fe2c..3e08a24 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1,6 +1,6 @@
 /* bnx2x.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -26,8 +26,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.78.01-0"
-#define DRV_MODULE_RELDATE      "2012/10/30"
+#define DRV_MODULE_VERSION      "1.78.02-0"
+#define DRV_MODULE_RELDATE      "2013/01/14"
 #define BNX2X_BC_VER            0x040200
 
 #if defined(CONFIG_DCB)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 963eb2d..42fe3c7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1,6 +1,6 @@
 /* bnx2x_cmn.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 8104b98..faad34f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1,6 +1,6 @@
 /* bnx2x_cmn.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 10bc093..37a2e9a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -1,6 +1,6 @@
 /* bnx2x_dcb.c: Broadcom Everest network driver.
  *
- * Copyright 2009-2012 Broadcom Corporation
+ * Copyright 2009-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
index 06c7a04..d153f44 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
@@ -1,6 +1,6 @@
 /* bnx2x_dcb.h: Broadcom Everest network driver.
  *
- * Copyright 2009-2012 Broadcom Corporation
+ * Copyright 2009-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 53374de..e05e5fc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1,6 +1,6 @@
 /* bnx2x_ethtool.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 60a83ad..2959f2a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
index 4bed52b..f572ae1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_file_hdr.h: FW binary file header structure.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index d2e79be..76e30c9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1,6 +1,6 @@
 /* bnx2x_hsi.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
index c8f10f0..76df015 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
@@ -1,7 +1,7 @@
 /* bnx2x_init.h: Broadcom Everest network driver.
  *               Structures and macroes needed during the initialization.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index d755acf..ae9b6ff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -2,7 +2,7 @@
  *               Static functions needed during the initialization.
  *               This file is "included" in bnx2x_main.c.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index cb41f54..859df75 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -1,4 +1,4 @@
-/* Copyright 2008-2012 Broadcom Corporation
+/* Copyright 2008-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index ee6e7ec..d25c7d7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -1,4 +1,4 @@
-/* Copyright 2008-2012 Broadcom Corporation
+/* Copyright 2008-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ac09abd..4b0217b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1,6 +1,6 @@
 /* bnx2x_main.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
index ddd5106..caf1aef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
@@ -1,6 +1,6 @@
 /* bnx2x_mfw_req.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2012 Broadcom Corporation
+ * Copyright (c) 2012-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index dec014e..791eb2d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1,6 +1,6 @@
 /* bnx2x_reg.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 147933a..8e8c91a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -1,6 +1,6 @@
 /* bnx2x_sp.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2011-2012 Broadcom Corporation
+ * Copyright (c) 2011-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index b304678..0beac4b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -1,6 +1,6 @@
 /* bnx2x_sp.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2011-2012 Broadcom Corporation
+ * Copyright (c) 2011-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 08db503..5e45cb9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1,6 +1,6 @@
 /* bnx2x_sriov.c: Broadcom Everest network driver.
  *
- * Copyright 2009-2012 Broadcom Corporation
+ * Copyright 2009-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index df4ae74..d51189b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -1,6 +1,6 @@
 /* bnx2x_sriov.h: Broadcom Everest network driver.
  *
- * Copyright 2009-2012 Broadcom Corporation
+ * Copyright 2009-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 93a8e74..18c2e61 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1,6 +1,6 @@
 /* bnx2x_stats.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index b4d7b26..63a2f85 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -1,6 +1,6 @@
 /* bnx2x_stats.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2012 Broadcom Corporation
+ * Copyright (c) 2007-2013 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 850aad3..9cef520 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1,6 +1,6 @@
 /* bnx2x_vfpf.c: Broadcom Everest network driver.
  *
- * Copyright 2009-2012 Broadcom Corporation
+ * Copyright 2009-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index 21d2985..a74477c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -1,6 +1,6 @@
 /* bnx2x_vfpf.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2011-2012 Broadcom Corporation
+ * Copyright (c) 2011-2013 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
-- 
1.8.1.227.g44fe835
