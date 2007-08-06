From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH] drivers/net/wireless/wl3501_cs.c: remove redundant memset
Date: Tue, 7 Aug 2007 00:50:22 +0200
Message-ID: <200708070050.23158.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: acme@ghostprotocols.net, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:4310 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761022AbXHFWuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 18:50:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

	This memset() looks superfluous.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/wireless/wl3501_cs.c | 58885 -> 58858 (-27 bytes)
 drivers/net/wireless/wl3501_cs.o | 200252 -> 200000 (-252 bytes)

 drivers/net/wireless/wl3501_cs.c |    1 -
 1 file changed, 1 deletion(-)

--- linux-2.6.23-rc1-mm2-a/drivers/net/wireless/wl3501_cs.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/wireless/wl3501_cs.c	2007-08-07 00:34:36.000000000 +0200
@@ -1841,7 +1841,6 @@ static int wl3501_get_encode(struct net_
 	tocopy = min_t(u8, len_keys, wrqu->encoding.length);
 	tocopy = min_t(u8, tocopy, 100);
 	wrqu->encoding.length = tocopy;
-	memset(extra, 0, tocopy);
 	memcpy(extra, keys, tocopy);
 out:
 	return rc;
