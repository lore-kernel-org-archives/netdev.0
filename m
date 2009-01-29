From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/20] sfc: SFT9001: Always enable XNP exchange on SFT9001
	rev B
Date: Thu, 29 Jan 2009 19:20:10 +0000
Message-ID: <1233256810.3656.35.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:49287 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753844AbZA2TUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:20:12 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This workaround is not specific to rev A.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/workarounds.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 420fe15..b810dcd 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -54,7 +54,7 @@
 #define EFX_WORKAROUND_8071 EFX_WORKAROUND_FALCON_A
 
 /* Need to send XNP pages for 100BaseT */
-#define EFX_WORKAROUND_13204 EFX_WORKAROUND_SFT9001A
+#define EFX_WORKAROUND_13204 EFX_WORKAROUND_SFT9001
 /* Need to keep AN enabled */
 #define EFX_WORKAROUND_13963 EFX_WORKAROUND_SFT9001A
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

