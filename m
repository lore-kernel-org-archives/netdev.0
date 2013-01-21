From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 1/2] NTB: disable x86_32 support
Date: Mon, 21 Jan 2013 15:28:51 -0700
Message-ID: <1358807332-22782-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atomic readq and writeq do not exist by default on some 32bit
architectures, thus causing compile errors due to non-existent symbols.
Since NTB has not been tested 32bit, disable x86_32 support until such
time as this and any other issues can be properly discovered.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ntb/Kconfig b/drivers/ntb/Kconfig
index f69df793..37ee649 100644
--- a/drivers/ntb/Kconfig
+++ b/drivers/ntb/Kconfig
@@ -1,7 +1,7 @@
 config NTB
        tristate "Intel Non-Transparent Bridge support"
        depends on PCI
-       depends on X86
+       depends on X86_64
        help
         The PCI-E Non-transparent bridge hardware is a point-to-point PCI-E bus
         connecting 2 systems.  When configured, writes to the device's PCI
-- 
1.7.9.5
