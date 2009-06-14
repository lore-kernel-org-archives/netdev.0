From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/2] Bluetooth: Fix Kconfig issue with RFKILL integration
Date: Sun, 14 Jun 2009 15:39:10 +0200
Message-ID: <1a097181ee8b0c492c021eb3dbaa5f9cd813ad0e.1244986258.git.marcel@holtmann.org>
References: <cover.1244986258.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55477 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430AbZFNNjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 09:39:16 -0400
In-Reply-To: <cover.1244986258.git.marcel@holtmann.org>
In-Reply-To: <cover.1244986258.git.marcel@holtmann.org>
References: <cover.1244986258.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the re-write of the RFKILL subsystem it is no longer good to just
select RFKILL, but it is important to add a proper depends on rule.

Based on a report by Alexander Beregalov <a.beregalov@gmail.com>

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
index 7725da9..59fdb1d 100644
--- a/net/bluetooth/Kconfig
+++ b/net/bluetooth/Kconfig
@@ -3,8 +3,9 @@
 #
 
 menuconfig BT
-	depends on NET && !S390
 	tristate "Bluetooth subsystem support"
+	depends on NET && !S390
+	depends on RFKILL || !RFKILL
 	help
 	  Bluetooth is low-cost, low-power, short-range wireless technology.
 	  It was designed as a replacement for cables and other short-range
-- 
1.6.2.2

