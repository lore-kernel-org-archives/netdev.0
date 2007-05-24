From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] ethtool: new ID to decode the registers of the 8168 (realtek)
Date: Thu, 24 May 2007 22:02:42 +0200
Message-ID: <20070524200242.GA17722@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58589 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906AbXEXUE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 16:04:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested with an Asrock 945G-DVI (LOM).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 realtek.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/realtek.c b/realtek.c
index 64ab7f8..8daba69 100644
--- a/realtek.c
+++ b/realtek.c
@@ -45,6 +45,7 @@ static struct chip_info {
 	{ "RTL-8100B/8139D",	HW_REVID(1, 1, 1, 0, 1, 0, 1) },
 	{ "RTL-8139C+",		HW_REVID(1, 1, 1, 0, 1, 1, 0) },
 	{ "RTL-8101",		HW_REVID(1, 1, 1, 0, 1, 1, 1) },
+	{ "RTL-8168B/8111B",	HW_REVID(0, 1, 1, 1, 0, 0, 0) },
 	{ "RTL-8169",		HW_REVID(0, 0, 0, 0, 0, 0, 0) },
 	{ "RTL-8169s",		HW_REVID(0, 0, 0, 0, 1, 0, 0) },
 	{ "RTL-8110",		HW_REVID(0, 0, 1, 0, 0, 0, 0) },
-- 
1.5.2

