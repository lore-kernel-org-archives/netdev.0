From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/62] 3c501: Use static const
Date: Sat, 20 Nov 2010 18:38:02 -0800
Message-ID: <c8433be50e87f26df24850d5b767d102e9abef3c.1290305775.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1629 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152Ab0KUCjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:39:41 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   9927	    472	   2128	  12527	   30ef	drivers/net/3c501.o.new
   9915	    484	   2128	  12527	   30ef	drivers/net/3c501.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/3c501.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 1776ab6..9e1c03e 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -158,8 +158,8 @@ static int mem_start;
 struct net_device * __init el1_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
-	static unsigned ports[] = { 0x280, 0x300, 0};
-	unsigned *port;
+	static const unsigned ports[] = { 0x280, 0x300, 0};
+	const unsigned *port;
 	int err = 0;
 
 	if (!dev)
-- 
1.7.3.2.245.g03276.dirty

