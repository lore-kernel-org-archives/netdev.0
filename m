From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH] firmware: Remove obsolete Chelsio cxgb3 firmware
Date: Wed,  1 Aug 2012 13:17:50 -0600
Message-ID: <1343848670-31504-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	James Bottomley <JBottomley@Parallels.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current firmware version used by the device driver
is 7.12.0

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: James Bottomley <JBottomley@Parallels.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Divy Le Ray <divy@chelsio.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 firmware/Makefile                   |    1 -
 firmware/cxgb3/t3fw-7.10.0.bin.ihex | 1935 -----------------------------------
 2 files changed, 1936 deletions(-)
 delete mode 100644 firmware/cxgb3/t3fw-7.10.0.bin.ihex

diff --git a/firmware/Makefile b/firmware/Makefile
index 344713b..76628e3 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -43,7 +43,6 @@ fw-shipped-$(CONFIG_CASSINI) += sun/cassini.bin
 fw-shipped-$(CONFIG_COMPUTONE) += intelliport2.bin
 fw-shipped-$(CONFIG_CHELSIO_T3) += cxgb3/t3b_psram-1.1.0.bin \
 				   cxgb3/t3c_psram-1.1.0.bin \
-				   cxgb3/t3fw-7.10.0.bin \
 				   cxgb3/ael2005_opt_edc.bin \
 				   cxgb3/ael2005_twx_edc.bin \
 				   cxgb3/ael2020_twx_edc.bin
diff --git a/firmware/cxgb3/t3fw-7.10.0.bin.ihex b/firmware/cxgb3/t3fw-7.10.0.bin.ihex
deleted file mode 100644
index 96399d8..0000000
-- 
1.7.9.5
