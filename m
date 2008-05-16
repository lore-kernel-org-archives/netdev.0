From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/16] sfc: Do not define inline macro
Date: Fri, 16 May 2008 21:19:05 +0100
Message-ID: <20080516201905.GD28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53572 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755636AbYEPUU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:20:26 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 77418ae..be09180 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -81,11 +81,6 @@ do {if (net_ratelimit()) EFX_INFO(efx, fmt, ##args); } while (0)
 #define EFX_LOG_RL(efx, fmt, args...) \
 do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); } while (0)
 
-/* Kernel headers may redefine inline anyway */
-#ifndef inline
-#define inline inline __attribute__ ((always_inline))
-#endif
-
 /**************************************************************************
  *
  * Efx data structures

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
