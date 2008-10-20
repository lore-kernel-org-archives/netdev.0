From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] sis190: add identifier for Atheros AR8021 PHY
Date: Mon, 20 Oct 2008 23:37:55 +0200
Message-ID: <20081020213755.GB19486@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pablomme@googlemail.com,
	coenraad@wish.org.za, bugzilla@bennee.com,
	leandro@dataworks.com.br, herton@mandriva.com.br,
	nagura-s@ck.tnc.ne.jp
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36678 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755470AbYJTVih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 17:38:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes http://bugzilla.kernel.org/show_bug.cgi?id=10994

Contributed by pablomme@googlemail.com, coenraad@wish.org.za
and a few others.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 3fe0176..e6e3bf5 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -317,6 +317,7 @@ static struct mii_chip_info {
         unsigned int type;
 	u32 feature;
 } mii_chip_table[] = {
+	{ "Atheros PHY AR8012",   { 0x004d, 0xd020 }, LAN, 0 },
 	{ "Broadcom PHY BCM5461", { 0x0020, 0x60c0 }, LAN, F_PHY_BCM5461 },
 	{ "Broadcom PHY AC131",   { 0x0143, 0xbc70 }, LAN, 0 },
 	{ "Agere PHY ET1101B",    { 0x0282, 0xf010 }, LAN, 0 },
-- 
1.5.3.3

