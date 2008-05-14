From: akpm@linux-foundation.org
Subject: [patch 11/11] net/s2io: set_rxd_buffer_pointer returns -ENOMEM, not ENOMEM
Date: Wed, 14 May 2008 16:20:17 -0700
Message-ID: <200805142320.m4ENKLnY026647@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	marcin.slusarz@gmail.com, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50472 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754654AbYENXVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:21:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcin Slusarz <marcin.slusarz@gmail.com>

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/s2io.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/s2io.c~net-s2io-set_rxd_buffer_pointer-returns-enomem-not-enomem drivers/net/s2io.c
--- a/drivers/net/s2io.c~net-s2io-set_rxd_buffer_pointer-returns-enomem-not-enomem
+++ a/drivers/net/s2io.c
@@ -6951,7 +6951,7 @@ static  int rxd_owner_bit_reset(struct s
 						       &skb,(u64 *)&temp0_64,
 						       (u64 *)&temp1_64,
 						       (u64 *)&temp2_64,
-							size) == ENOMEM) {
+							size) == -ENOMEM) {
 					return 0;
 				}
 
_
