From: Rudy Matela <rudy.matela@gmail.com>
Subject: [PATCH] net: Coding style corrections on Sealevel Systems 4021
 driver.
Date: Sat, 28 Nov 2009 23:49:44 -0300
Message-ID: <20091129024944.GB20636@oblivion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:43881 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbZK2Cs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 21:48:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed braces position on some statements.
Inserted a space between an "if" keyword and a parenthesis.

Signed-off-by: Rudy Matela <rudy.matela@gmail.com>
---

 drivers/net/wan/sealevel.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 0c525e2..6b03704 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -84,8 +84,7 @@ static int sealevel_open(struct net_device *d)
 	 *	Link layer up.
 	 */
 
-	switch (unit)
-	{
+	switch (unit) {
 		case 0:
 			err = z8530_sync_dma_open(d, slvl->chan);
 			break;
@@ -133,8 +132,7 @@ static int sealevel_close(struct net_device *d)
 	hdlc_close(d);
 	netif_stop_queue(d);
 
-	switch (unit)
-	{
+	switch (unit) {
 		case 0:
 			z8530_sync_dma_close(d, slvl->chan);
 			break;
@@ -342,8 +340,7 @@ static void __exit slvl_shutdown(struct slvl_board *b)
 
 	z8530_shutdown(&b->board);
 
-	for (u = 0; u < 2; u++)
-	{
+	for (u = 0; u < 2; u++) {
 		struct net_device *d = b->dev[u].chan->netdevice;
 		unregister_hdlc_device(d);
 		free_netdev(d);
@@ -391,7 +388,7 @@ static int __init slvl_init_module(void)
 
 static void __exit slvl_cleanup_module(void)
 {
-	if(slvl_unit)
+	if (slvl_unit)
 		slvl_shutdown(slvl_unit);
 }
 
