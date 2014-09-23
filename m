From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v4 9/9] ARM: dts: berlin: enable the Ethernet port on the BG2Q DMP
Date: Tue, 23 Sep 2014 14:15:36 +0200
Message-ID: <1411474536-22626-10-git-send-email-antoine.tenart@free-electrons.com>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:57123 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755386AbaIWMPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 08:15:46 -0400
In-Reply-To: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the Ethernet port on the Marvell Berlin2Q DMP board.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 arch/arm/boot/dts/berlin2q-marvell-dmp.dts | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm/boot/dts/berlin2q-marvell-dmp.dts b/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
index a357ce02a64e..ea1f99b8eed6 100644
--- a/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
+++ b/arch/arm/boot/dts/berlin2q-marvell-dmp.dts
@@ -45,3 +45,7 @@
 &uart0 {
 	status = "okay";
 };
+
+&eth0 {
+	status = "okay";
+};
-- 
1.9.1
