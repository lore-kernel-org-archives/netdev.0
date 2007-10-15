From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] Jazzsonic: Fix warning about unused variable.
Date: Mon, 15 Oct 2007 10:58:40 +0100
Message-ID: <20071015095840.GA30451@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:55422 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758053AbXJOJ6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:58:45 -0400
Received: from localhost.localdomain ([127.0.0.1]:38884 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20034517AbXJOJ6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 10:58:44 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Caused by "[NET]: Introduce and use print_mac() and DECLARE_MAC_BUF()"
aka 0795af5729b18218767fab27c44b1384f72dc9ad.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index d3825c8..5c154fe 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -208,7 +208,6 @@ static int __init jazz_sonic_probe(struct platform_device *pdev)
 	struct sonic_local *lp;
 	struct resource *res;
 	int err = 0;
-	int i;
 	DECLARE_MAC_BUF(mac);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
