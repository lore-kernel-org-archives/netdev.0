From: Mark Brown <broonie@kernel.org>
Subject: [PATCH 2/2] net: asix: Move declaration of ax88172a_info to shared header
Date: Fri,  9 Aug 2013 18:31:22 +0100
Message-ID: <1376069482-16951-2-git-send-email-broonie@kernel.org>
References: <1376069482-16951-1-git-send-email-broonie@kernel.org>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, Mark Brown <broonie@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:48319 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758309Ab3HIRbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 13:31:34 -0400
In-Reply-To: <1376069482-16951-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@linaro.org>

Ensure that the definition of ax88172a_info matches the declaration seen
by users and silence sparse warnings about symbols without declarations
in the global namespace by moving the declaration into the shared header
asix.h.

Signed-off-by: Mark Brown <broonie@linaro.org>
---
 drivers/net/usb/asix.h         | 2 ++
 drivers/net/usb/asix_devices.c | 2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index 346c032..bdaa12d 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -178,6 +178,8 @@ struct asix_common_private {
 	struct asix_rx_fixup_info rx_fixup_info;
 };
 
+extern const struct driver_info ax88172a_info;
+
 /* ASIX specific flags */
 #define FLAG_EEPROM_MAC		(1UL << 0)  /* init device MAC from eeprom */
 
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index b96ad4f..386a3df 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -946,8 +946,6 @@ static const struct driver_info hg20f9_info = {
 	.data = FLAG_EEPROM_MAC,
 };
 
-extern const struct driver_info ax88172a_info;
-
 static const struct usb_device_id	products [] = {
 {
 	// Linksys USB200M
-- 
1.8.4.rc1
