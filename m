From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH 6/6] net: moxa: Fix module autoload for OF platform driver
Date: Fri, 18 Sep 2015 17:56:21 +0200
Message-ID: <20150918155621.GA24887@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	=?unknown-8bit?B?ZnJhbsOnb2lz?= romieu <romieu@fr.zoreil.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Joe Perches <joe@perches.com>,
	Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38585 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960AbbIRP4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 11:56:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This platform driver has a OF device ID table but the OF module
alias information is not created so module autoloading won't work.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index becbb5f..a10c928 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -552,6 +552,7 @@ static const struct of_device_id moxart_mac_match[] = {
 	{ .compatible = "moxa,moxart-mac" },
 	{ }
 };
+MODULE_DEVICE_TABLE(of, moxart_mac_match);
 
 static struct platform_driver moxart_mac_driver = {
 	.probe	= moxart_mac_probe,
-- 
2.4.6
