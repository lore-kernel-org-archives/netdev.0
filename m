From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 5/5] dcb: fix sparse warnings
Date: Fri, 08 Mar 2013 11:07:44 -0800
Message-ID: <20130308190809.541295922@vyatta.com>
References: <20130308190739.260966567@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:37278 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580Ab3CHTXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 14:23:33 -0500
Content-Disposition: inline; filename=dcb-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add header with function definitions to quiet warnings and avoid future errors.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/dcb/dcbevent.c	2012-12-07 15:06:43.291665973 -0800
+++ b/net/dcb/dcbevent.c	2013-03-08 10:36:52.394147858 -0800
@@ -20,6 +20,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/notifier.h>
 #include <linux/export.h>
+#include <net/dcbevent.h>
 
 static ATOMIC_NOTIFIER_HEAD(dcbevent_notif_chain);
 
