From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] ethtool: new ID to decode the registers of the 8101E (realtek)
Date: Wed, 30 May 2007 13:44:03 +0200
Message-ID: <20070530114403.GA17914@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rolf Eike Beer <eike-kernel@sf-tec.de>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35995 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753954AbXE3LsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 07:48:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Rolf Eike Beer <eike-kernel@sf-tec.de>
---
 realtek.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/realtek.c b/realtek.c
index 8daba69..c56b3f5 100644
--- a/realtek.c
+++ b/realtek.c
@@ -46,6 +46,7 @@ static struct chip_info {
 	{ "RTL-8139C+",		HW_REVID(1, 1, 1, 0, 1, 1, 0) },
 	{ "RTL-8101",		HW_REVID(1, 1, 1, 0, 1, 1, 1) },
 	{ "RTL-8168B/8111B",	HW_REVID(0, 1, 1, 1, 0, 0, 0) },
+	{ "RTL-8101E",		HW_REVID(0, 1, 1, 0, 1, 0, 0) },
 	{ "RTL-8169",		HW_REVID(0, 0, 0, 0, 0, 0, 0) },
 	{ "RTL-8169s",		HW_REVID(0, 0, 0, 0, 1, 0, 0) },
 	{ "RTL-8110",		HW_REVID(0, 0, 1, 0, 0, 0, 0) },
-- 
1.5.2
