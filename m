From: Patrick McHardy <kaber@trash.net>
Subject: [PACKET]: Kill unused pg_vec_endpage() function
Date: Thu, 18 Oct 2007 18:09:45 +0200
Message-ID: <47178549.3070107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000800050503000609000008"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41358 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983AbXJRQKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 12:10:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000800050503000609000008
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000800050503000609000008
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[PACKET]: Kill unused pg_vec_endpage() function

The conversion to vm_insert_page() left this unused function behind,
remove it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e11000a..d093650 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1623,11 +1623,6 @@ static struct vm_operations_struct packet_mmap_ops = {
 	.close =packet_mm_close,
 };
 
-static inline struct page *pg_vec_endpage(char *one_pg_vec, unsigned int order)
-{
-	return virt_to_page(one_pg_vec + (PAGE_SIZE << order) - 1);
-}
-
 static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
 {
 	int i;

--------------000800050503000609000008--
