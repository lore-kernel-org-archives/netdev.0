From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][26/37] Clean up duplicate includes in net/atm/
Date: Sat, 21 Jul 2007 17:03:34 +0200
Message-ID: <200707211703.34580.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jesper Juhl <jesper.juhl@gmail.com>, netdev@vger.kernel.org,
	Marko Kiiskila <mkiiskila@yahoo.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	David S Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:40095 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938249AbXGUPEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 11:04:34 -0400
Received: by ug-out-1314.google.com with SMTP id j3so799909ugf
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 08:04:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/atm/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 2770fb4..59d5aa3 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -21,7 +21,6 @@
 #include <net/dst.h>
 #include <linux/proc_fs.h>
 #include <linux/spinlock.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
 /* TokenRing if needed */
