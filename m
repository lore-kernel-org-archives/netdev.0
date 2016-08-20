From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Remove XSTRINGIFY macro definitions and uses
Date: Fri, 19 Aug 2016 23:19:48 -0700
Message-ID: <1471673991-117115-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:14738 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752102AbcHTGwH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:52:07 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use __stringify instead.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        | 4 ----
 drivers/net/ethernet/intel/i40e/i40e_client.h | 6 +++---
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 8dc98c2..747ef2d 100644
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
2.7.4
