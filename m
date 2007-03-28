From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] sis190: new PHY support
Date: Thu, 29 Mar 2007 00:18:50 +0200
Message-ID: <20070328221850.GA10571@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Paul Gibbons <paul@pkami.e7even.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48015 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933921AbXC1WUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 18:20:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reported to work on the WinFast 761GXK8MB-RS motherboard.

Plain 10/100 Mbps.

Signed-off-by: Paul Gibbons <paul@pkami.e7even.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b08508b..34463ce 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -324,6 +324,7 @@ static struct mii_chip_info {
 	u32 feature;
 } mii_chip_table[] = {
 	{ "Broadcom PHY BCM5461", { 0x0020, 0x60c0 }, LAN, F_PHY_BCM5461 },
+	{ "Broadcom PHY AC131",   { 0x0143, 0xbc70 }, LAN, 0 },
 	{ "Agere PHY ET1101B",    { 0x0282, 0xf010 }, LAN, 0 },
 	{ "Marvell PHY 88E1111",  { 0x0141, 0x0cc0 }, LAN, F_PHY_88E1111 },
 	{ "Realtek PHY RTL8201",  { 0x0000, 0x8200 }, LAN, 0 },
-- 
1.5.0.5

