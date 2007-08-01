From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH] Removal of duplicated include net/wanrouter/wanmain.c
Date: Wed, 01 Aug 2007 19:58:53 +0200
Message-ID: <46B0C9DD.8040701@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:40332 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764381AbXHAR7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 13:59:25 -0400
Received: by nf-out-0910.google.com with SMTP id g13so73300nfb
        for <netdev@vger.kernel.org>; Wed, 01 Aug 2007 10:59:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

There is no need to include linux/init.h twice

Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

--- linux-mm-clean/net/wanrouter/wanmain.c	2007-07-09 01:32:17.000000000 +0200
+++ linux-mm/net/wanrouter/wanmain.c	2007-08-01 18:14:22.000000000 +0200
@@ -46,7 +46,6 @@
 #include <linux/capability.h>
 #include <linux/errno.h>	/* return codes */
 #include <linux/kernel.h>
-#include <linux/init.h>
 #include <linux/module.h>	/* support for loadable modules */
 #include <linux/slab.h>		/* kmalloc(), kfree() */
 #include <linux/mm.h>
