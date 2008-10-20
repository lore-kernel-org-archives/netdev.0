From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 1/3] smc911x: Allow Kconfig dependency on ARM
Date: Mon, 20 Oct 2008 18:15:17 +0100
Message-ID: <20081020171217.6277.20729.stgit@pc1117.cambridge.arm.com>
References: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:52986 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752504AbYJTRkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:40:22 -0400
In-Reply-To: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since more ARM platforms use this device, it is easier to add a
dependency on ARM rather than individual platforms.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

This patch will conflict with a patch posted two days ago -
http://marc.info/?l=linux-netdev&m=122436376803634&w=2. However,
Guennadi suggested that it is better to have the dependency on ARM
rather than individual ARM platforms.


 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ad301ac..ef38f01 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -960,7 +960,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SUPERH
+	depends on ARM || SUPERH
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.

