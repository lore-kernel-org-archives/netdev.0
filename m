From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?= <Uwe.Kleine-Koenig@digi.com>
Subject: [PATCH] trivial: fix alignment of IP-Config output
Date: Tue, 12 Feb 2008 09:38:46 +0100
Message-ID: <1202805526-646-1-git-send-email-Uwe.Kleine-Koenig@digi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail29.messagelabs.com ([216.82.249.147]:38234 "HELO
	mail29.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751071AbYBLIiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 03:38:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make the intended lines aligned in the output (not in the code)

Signed-off-by: Uwe Kleine-K=C3=B6nig <Uwe.Kleine-Koenig@digi.com>
---
 net/ipv4/ipconfig.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index a52b585..10013cc 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1390,7 +1390,7 @@ static int __init ip_auto_config(void)
 	 * Clue in the operator.
 	 */
 	printk("IP-Config: Complete:");
-	printk("\n      device=3D%s", ic_dev->name);
+	printk("\n     device=3D%s", ic_dev->name);
 	printk(", addr=3D%u.%u.%u.%u", NIPQUAD(ic_myaddr));
 	printk(", mask=3D%u.%u.%u.%u", NIPQUAD(ic_netmask));
 	printk(", gw=3D%u.%u.%u.%u", NIPQUAD(ic_gateway));
--=20
1.5.4

