From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/16] sfc: Use __packed macro
Date: Fri, 16 May 2008 21:19:21 +0100
Message-ID: <20080516201921.GE28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53558 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754897AbYEPUTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:19:42 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_hwdefs.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 06e2d68..6d00311 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -1125,7 +1125,7 @@ struct falcon_nvconfig_board_v2 {
 	u8 port1_phy_type;
 	__le16 asic_sub_revision;
 	__le16 board_revision;
-} __attribute__ ((packed));
+} __packed;
 
 #define NVCONFIG_BASE 0x300
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
@@ -1144,6 +1144,6 @@ struct falcon_nvconfig {
 	__le16 board_struct_ver;
 	__le16 board_checksum;
 	struct falcon_nvconfig_board_v2 board_v2;
-} __attribute__ ((packed));
+} __packed;
 
 #endif /* EFX_FALCON_HWDEFS_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
