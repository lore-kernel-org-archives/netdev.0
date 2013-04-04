From: Thierry Reding <thierry@gilfi.de>
Subject: [PATCH ethtool] realtek: Support the RTL-8168/8111B
Date: Thu,  4 Apr 2013 22:44:03 +0200
Message-ID: <1365108243-15591-1-git-send-email-thierry@gilfi.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dotsec.net ([62.75.224.215]:59231 "EHLO styx.dotsec.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764841Ab3DDVa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 17:30:56 -0400
Received: from port-2201.pppoe.wtnet.de ([84.46.8.161] helo=localhost)
	by styx.dotsec.net with esmtpa (Exim 4.71)
	(envelope-from <thierry@gilfi.de>)
	id 1UNr0y-0004O8-R6
	for netdev@vger.kernel.org; Thu, 04 Apr 2013 22:44:21 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This card can for instance be found in CompuLab TrimSlice devices.

Signed-off-by: Thierry Reding <thierry@gilfi.de>
---
 realtek.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/realtek.c b/realtek.c
index c3d7ae5..8ecd9a2 100644
--- a/realtek.c
+++ b/realtek.c
@@ -28,6 +28,7 @@ enum chip_type {
 	RTL8169_8110SB,
 	RTL8169_8110SCd,
 	RTL8169_8110SCe,
+	RTL8168_8111B,
 	RTL8168_8111Bb,
 	RTL8168_8111Bef,
 	RTL8101Ebc,
@@ -60,6 +61,7 @@ static struct chip_info {
 	{ "RTL-8169/8110SB",	HW_REVID(0, 0, 0, 1, 0, 0, 0, 0) },
 	{ "RTL-8169/8110SCd",	HW_REVID(0, 0, 0, 1, 1, 0, 0, 0) },
 	{ "RTL-8169/8110SCe",	HW_REVID(1, 0, 0, 1, 1, 0, 0, 0) },
+	{ "RTL-8168/8111B",	HW_REVID(0, 0, 1, 0, 1, 0, 0, 0) },
 	{ "RTL-8168/8111Bb",	HW_REVID(0, 0, 1, 1, 0, 0, 0, 0) },
 	{ "RTL-8168/8111Bef",	HW_REVID(0, 0, 1, 1, 1, 0, 0, 0) },
 	{ "RTL-8101Ebc",	HW_REVID(0, 0, 1, 1, 0, 1, 0, 0) },
-- 
1.8.2
