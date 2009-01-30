From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/11] sfc: SFT9001: Always enable XNP exchange on SFT9001 rev B
Date: Fri, 30 Jan 2009 03:52:11 +0000
Message-ID: <20090130035210.GK15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:59512 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754476AbZA3DwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:52:13 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
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
