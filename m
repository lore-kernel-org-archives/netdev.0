From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/6] sfc: Correct address of gPXE boot configuration in EEPROM
Date: Tue, 4 Nov 2008 20:32:45 +0000
Message-ID: <20081104203244.GX7331@solarflare.com>
References: <20081104203117.GW7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:52791 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753149AbYKDUcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:32:55 -0500
Content-Disposition: inline
In-Reply-To: <20081104203117.GW7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a hardware bug, the originally assigned range cannot reliably
be used for boot configuration and must not be modifiable through
ethtool.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index fa98af5..cd0d087 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -174,8 +174,8 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
 
 /* EEPROM range with gPXE configuration */
 #define EFX_ETHTOOL_EEPROM_MAGIC 0xEFAB
-#define EFX_ETHTOOL_EEPROM_MIN 0x100U
-#define EFX_ETHTOOL_EEPROM_MAX 0x400U
+#define EFX_ETHTOOL_EEPROM_MIN 0x800U
+#define EFX_ETHTOOL_EEPROM_MAX 0x1800U
 
 /**************************************************************************
  *
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
