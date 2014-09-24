From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/4] parisc: Update defconfigs which were missing
 CONFIG_NET.
Date: Wed, 24 Sep 2014 14:49:29 -0400 (EDT)
Message-ID: <20140924.144929.1831753286382773236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684AbaIXSta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:49:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
'select'.")  removed what happened to be the only instance of 'select
NET'. Defconfigs that were relying on the select now lack networking
support.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/parisc/configs/a500_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/parisc/configs/a500_defconfig b/arch/parisc/configs/a500_defconfig
index 9002532..0490199 100644
--- a/arch/parisc/configs/a500_defconfig
+++ b/arch/parisc/configs/a500_defconfig
@@ -31,6 +31,7 @@ CONFIG_PD6729=m
 CONFIG_I82092=m
 # CONFIG_SUPERIO is not set
 # CONFIG_CHASSIS_LCD_LED is not set
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_XFRM_USER=m
-- 
1.7.11.7
