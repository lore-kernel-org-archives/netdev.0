From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH 1/3] sis190: add new phy found on asus F5 series laptops
Date: Tue, 2 Jun 2009 09:52:10 +0000 (UTC)
Message-ID: <20090603095236.GA15414@localhost>
References: <cover.1244012631.git.birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp12.tin.it ([212.216.176.206]:50151 "EHLO vsmtp12.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbZFBJv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 05:51:59 -0400
Date: Wed, 3 Jun 2009 11:52:36 +0200
Content-Disposition: inline
In-Reply-To: <cover.1244012631.git.birrachiara@tin.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
---
 drivers/net/sis190.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 55ccd51..3d4542e 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -317,6 +317,7 @@ static struct mii_chip_info {
         unsigned int type;
 	u32 feature;
 } mii_chip_table[] = {
+	{ "Atheros PHY ?",        { 0x004d, 0xd010 }, LAN, 0 },
 	{ "Atheros PHY AR8012",   { 0x004d, 0xd020 }, LAN, 0 },
 	{ "Broadcom PHY BCM5461", { 0x0020, 0x60c0 }, LAN, F_PHY_BCM5461 },
 	{ "Broadcom PHY AC131",   { 0x0143, 0xbc70 }, LAN, 0 },
-- 
1.6.2.4

