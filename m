From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][31/37] Clean up duplicate includes in net/sched/
Date: Sat, 21 Jul 2007 17:03:49 +0200
Message-ID: <200707211703.49812.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	David S Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:37344 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939504AbXGUPEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 11:04:46 -0400
Received: by ug-out-1314.google.com with SMTP id j3so799632ugf
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2007 08:04:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch cleans up duplicate includes in
	net/sched/


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index bf90e60..6085be5 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -16,7 +16,6 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
-#include <linux/module.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <net/act_api.h>
