From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4] powerpc: Update defconfigs which were missing
 CONFIG_NET.
Date: Wed, 24 Sep 2014 14:49:26 -0400 (EDT)
Message-ID: <20140924.144926.1013677655715591915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562AbaIXSt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:49:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
'select'.")  removed what happened to be the only instance of 'select
NET'. Defconfigs that were relying on the select now lack networking
support.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/powerpc/configs/c2k_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/configs/c2k_defconfig b/arch/powerpc/configs/c2k_defconfig
index 5e2aa43..5973491 100644
--- a/arch/powerpc/configs/c2k_defconfig
+++ b/arch/powerpc/configs/c2k_defconfig
@@ -29,6 +29,7 @@ CONFIG_PM=y
 CONFIG_PCI_MSI=y
 CONFIG_HOTPLUG_PCI=y
 CONFIG_HOTPLUG_PCI_SHPC=m
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_XFRM_USER=y
-- 
1.7.11.7
