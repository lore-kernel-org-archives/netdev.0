From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/2] netdev: bfin_mac: enable bfin_mac net dev driver for BF51x
Date: Thu,  8 Jan 2009 00:14:38 +0800
Message-ID: <1231344879-26069-2-git-send-email-cooloney@kernel.org>
References: <1231344879-26069-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sonic Zhang <sonic.zhang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:41340 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbZAGQN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:13:56 -0500
In-Reply-To: <1231344879-26069-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9a18270..6b1eb43 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -830,7 +830,7 @@ config ULTRA32
 
 config BFIN_MAC
 	tristate "Blackfin on-chip MAC support"
-	depends on NET_ETHERNET && (BF526 || BF527 || BF536 || BF537)
+	depends on NET_ETHERNET && (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
 	select CRC32
 	select MII
 	select PHYLIB
-- 
1.5.6

