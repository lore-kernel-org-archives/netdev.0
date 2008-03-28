From: akpm@linux-foundation.org
Subject: [patch 3/4] lapb: use the shorter LIST_HEAD form for brevity
Date: Fri, 28 Mar 2008 14:37:31 -0700
Message-ID: <200803282137.m2SLbV8H011632@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rpjday@crashcourse.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49527 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757841AbYC1Vhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:37:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Robert P. J. Day" <rpjday@crashcourse.ca>

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/lapbether.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wan/lapbether.c~lapb-use-the-shorter-list_head-form-for-brevity drivers/net/wan/lapbether.c
--- a/drivers/net/wan/lapbether.c~lapb-use-the-shorter-list_head-form-for-brevity
+++ a/drivers/net/wan/lapbether.c
@@ -58,7 +58,7 @@ struct lapbethdev {
 	struct net_device_stats stats;		/* some statistics */
 };
 
-static struct list_head lapbeth_devices = LIST_HEAD_INIT(lapbeth_devices);
+static LIST_HEAD(lapbeth_devices);
 
 /* ------------------------------------------------------------------------ */
 
_
