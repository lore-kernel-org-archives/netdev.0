From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/12] sfc: Remove another unused workaround macro
Date: Sat, 28 Nov 2009 15:35:30 +0000
Message-ID: <1259422530.3709.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59138 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbZK1Pf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:35:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/workarounds.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index bad0932..209ee1e 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -33,8 +33,6 @@
 #define EFX_WORKAROUND_10727 EFX_WORKAROUND_ALWAYS
 /* Transmit flow control may get disabled */
 #define EFX_WORKAROUND_11482 EFX_WORKAROUND_FALCON_AB
-/* Flush events can take a very long time to appear */
-#define EFX_WORKAROUND_11557 EFX_WORKAROUND_ALWAYS
 /* Truncated IPv4 packets can confuse the TX packet parser */
 #define EFX_WORKAROUND_15592 EFX_WORKAROUND_FALCON_AB
 
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

