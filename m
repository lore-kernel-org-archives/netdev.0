From: Joe Perches <joe@perches.com>
Subject: [PATCH] i40e: Remove XSTRINGIFY macro definitions and uses
Date: Wed, 17 Aug 2016 03:37:31 -0700
Message-ID: <2fcd71eb8b18415a020509e3ce116e3affa590b5.1471430183.git.joe@perches.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use __stringify instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        | 4 ----
 drivers/net/ethernet/intel/i40e/i40e_client.h | 6 +++---
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2a88291..9788981 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -120,10 +120,6 @@
 #define I40E_CURRENT_NVM_VERSION_HI 0x2
 #define I40E_CURRENT_NVM_VERSION_LO 0x40
 
-/* magic for getting defines into strings */
-#define STRINGIFY(foo)  #foo
-#define XSTRINGIFY(bar) STRINGIFY(bar)
-
 #define I40E_RX_DESC(R, i)			\
 	(&(((union i40e_32byte_rx_desc *)((R)->desc))[i]))
 #define I40E_TX_DESC(R, i)			\
diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.h b/drivers/net/ethernet/intel/i40e/i40e_client.h
index a4601d9..38a6c36 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.h
@@ -36,9 +36,9 @@
 #define I40E_CLIENT_VERSION_MINOR 01
 #define I40E_CLIENT_VERSION_BUILD 00
 #define I40E_CLIENT_VERSION_STR     \
-	XSTRINGIFY(I40E_CLIENT_VERSION_MAJOR) "." \
-	XSTRINGIFY(I40E_CLIENT_VERSION_MINOR) "." \
-	XSTRINGIFY(I40E_CLIENT_VERSION_BUILD)
+	__stringify(I40E_CLIENT_VERSION_MAJOR) "." \
+	__stringify(I40E_CLIENT_VERSION_MINOR) "." \
+	__stringify(I40E_CLIENT_VERSION_BUILD)
 
 struct i40e_client_version {
 	u8 major;
-- 
2.8.0.rc4.16.g56331f8
