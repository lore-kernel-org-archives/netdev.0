From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] __dst_free(): put EXPORT_SYMBOLS after the fct
Date: Tue, 20 Jul 2010 11:51:38 +0200
Message-ID: <4C4571AA.5060107@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020000030000040608060509"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:58679 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758545Ab0GTJvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 05:51:42 -0400
Received: by ewy23 with SMTP id 23so1567047ewy.19
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 02:51:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020000030000040608060509
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

this patch is just cosmetic: EXPORT_SYMBOLS(__dst_free) has been put after 
___dst_free() function instead of __dst_free().


Regards,

-- 
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 10
Fax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
www.6wind.com
Join the Multicore Packet Processing Forum: www.multicorepacketprocessing.com

Ce courriel ainsi que toutes les pièces jointes, est uniquement destiné à son ou 
ses destinataires. Il contient des informations confidentielles qui sont la 
propriété de 6WIND. Toute révélation, distribution ou copie des informations 
qu'il contient est strictement interdite. Si vous avez reçu ce message par 
erreur, veuillez immédiatement le signaler à l'émetteur et détruire toutes les 
données reçues.

This e-mail message, including any attachments, is for the sole use of the 
intended recipient(s) and contains information that is confidential and 
proprietary to 6WIND. All unauthorized review, use, disclosure or distribution 
is prohibited. If you are not the intended recipient, please contact the sender 
by reply e-mail and destroy all copies of the original message.

--------------020000030000040608060509
Content-Type: text/x-diff;
 name="0002-__dst_free-put-EXPORT_SYMBOLS-after-the-fct.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0002-__dst_free-put-EXPORT_SYMBOLS-after-the-fct.patch"

>From f96851b4d7e6125d8c0e5f4da7b6fffffd21b642 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 20 Jul 2010 11:38:20 +0200
Subject: [PATCH] __dst_free(): put EXPORT_SYMBOLS after the fct

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/dst.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 9920722..6c41b1f 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -197,7 +197,6 @@ static void ___dst_free(struct dst_entry *dst)
 		dst->input = dst->output = dst_discard;
 	dst->obsolete = 2;
 }
-EXPORT_SYMBOL(__dst_free);
 
 void __dst_free(struct dst_entry *dst)
 {
@@ -213,6 +212,7 @@ void __dst_free(struct dst_entry *dst)
 	}
 	spin_unlock_bh(&dst_garbage.lock);
 }
+EXPORT_SYMBOL(__dst_free);
 
 struct dst_entry *dst_destroy(struct dst_entry * dst)
 {
-- 
1.5.4.5


--------------020000030000040608060509--
