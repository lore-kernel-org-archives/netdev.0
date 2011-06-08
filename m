From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] e1000e: remove redundant reverse dependency on CRC32
Date: Wed,  8 Jun 2011 15:56:35 -0700
Message-ID: <1307573800-24868-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3611 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755057Ab1FHW4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 18:56:47 -0400
In-Reply-To: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Commit 5d03078a6804bf4c7f943c5b68bef80468c0717f added a redundant 'select
CRC32'; remove it.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 19f04a3..fa0ea6d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2115,7 +2115,6 @@ config E1000
 
 config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
-	select CRC32
 	depends on PCI && (!SPARC32 || BROKEN)
 	select CRC32
 	---help---
-- 
1.7.5.2

