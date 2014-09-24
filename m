From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4] mips: Update some more defconfigs which were missing
 CONFIG_NET.
Date: Wed, 24 Sep 2014 14:49:14 -0400 (EDT)
Message-ID: <20140924.144914.467369651395057588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbaIXStQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:49:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
'select'.")  removed what happened to be the only instance of 'select
NET'. Defconfigs that were relying on the select now lack networking
support.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/mips/configs/nlm_xlp_defconfig | 1 +
 arch/mips/configs/nlm_xlr_defconfig | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/mips/configs/nlm_xlp_defconfig b/arch/mips/configs/nlm_xlp_defconfig
index 2f660e9..70509a4 100644
--- a/arch/mips/configs/nlm_xlp_defconfig
+++ b/arch/mips/configs/nlm_xlp_defconfig
@@ -63,6 +63,7 @@ CONFIG_MIPS32_O32=y
 CONFIG_MIPS32_N32=y
 CONFIG_PM_RUNTIME=y
 CONFIG_PM_DEBUG=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_XFRM_USER=m
diff --git a/arch/mips/configs/nlm_xlr_defconfig b/arch/mips/configs/nlm_xlr_defconfig
index c6f8465..82207e8 100644
--- a/arch/mips/configs/nlm_xlr_defconfig
+++ b/arch/mips/configs/nlm_xlr_defconfig
@@ -43,6 +43,7 @@ CONFIG_PCI_DEBUG=y
 CONFIG_BINFMT_MISC=m
 CONFIG_PM_RUNTIME=y
 CONFIG_PM_DEBUG=y
+CONFIG_NET=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_XFRM_USER=m
-- 
1.7.11.7
