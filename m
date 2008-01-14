From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [TOKENRING]: rif_timer not initialized properly
Date: Mon, 14 Jan 2008 07:30:00 +0100
Message-ID: <478B0168.1060809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010704050106060601040502"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34472 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbYANGaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 01:30:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010704050106060601040502
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------010704050106060601040502
Content-Type: text/plain;
 name="tr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tr.patch"

diff --git a/net/802/tr.c b/net/802/tr.c
index a2bd0f2..1e115e5 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -642,7 +642,7 @@ struct net_device *alloc_trdev(int sizeof_priv)
 static int __init rif_init(void)
 {
 	init_timer(&rif_timer);
-	rif_timer.expires  = sysctl_tr_rif_timeout;
+	rif_timer.expires  = jiffies + sysctl_tr_rif_timeout;
 	rif_timer.data     = 0L;
 	rif_timer.function = rif_check_expire;
 	add_timer(&rif_timer);

--------------010704050106060601040502--
