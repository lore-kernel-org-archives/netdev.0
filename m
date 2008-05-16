From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/16] sfc: Remove sub-minor component from driver version
Date: Fri, 16 May 2008 21:21:06 +0100
Message-ID: <20080516202106.GI28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53583 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752913AbYEPUVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:21:49 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver has diverged from the out-of-tree driver to which the version
number originally applied.  It should be identified primarily by kernel
version.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index f4757e1..5e20e75 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -42,7 +42,7 @@
 #ifndef EFX_DRIVER_NAME
 #define EFX_DRIVER_NAME	"sfc"
 #endif
-#define EFX_DRIVER_VERSION	"2.2.0136"
+#define EFX_DRIVER_VERSION	"2.2"
 
 #ifdef EFX_ENABLE_DEBUG
 #define EFX_BUG_ON_PARANOID(x) BUG_ON(x)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
