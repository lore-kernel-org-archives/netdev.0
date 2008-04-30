From: gao changli <xiaosuo@gmail.com>
Subject: [PATCH] unify the macro get_u16 in the file tulip.h
Date: Thu, 1 May 2008 01:41:19 +0800
Message-ID: <2BC7F66F-0DCA-4D90-B44F-EFC74CB53892@gmail.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:34617 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757175AbYD3RlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 13:41:25 -0400
Received: by py-out-1112.google.com with SMTP id u52so964564pyb.10
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 10:41:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unify the macro get_u16 with le16_to_cpu.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---

  tulip.h |    6 +-----
  1 file changed, 1 insertion(+), 5 deletions(-)

--- linux/drivers/net/tulip/tulip.h	2008-04-30 23:25:24.000000000 +0800
+++ linux-new/drivers/net/tulip/tulip.h	2008-04-30 23:28:04.000000000  
+0800
@@ -299,11 +299,7 @@

  #define RUN_AT(x) (jiffies + (x))

-#if defined(__i386__)			/* AKA get_unaligned() */
-#define get_u16(ptr) (*(u16 *)(ptr))
-#else
-#define get_u16(ptr) (((u8*)(ptr))[0] + (((u8*)(ptr))[1]<<8))
-#endif
+#define get_u16(ptr) le16_to_cpu(*(u16*)(ptr))

  struct medialeaf {
  	u8 type;
