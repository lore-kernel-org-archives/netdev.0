From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [RFC][PATCH] Get rid of dead code in net/ipv4/fib_semantics.c
Date: Tue, 31 Jul 2007 22:36:43 +0200
Message-ID: <46AF9D5B.7010607@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Netdev" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:31400 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934237AbXGaUhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 16:37:06 -0400
Received: by nf-out-0910.google.com with SMTP id g13so250129nfb
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 13:37:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

File /home/devel/linux-rdc/net/ipv4/fib_semantics.c line 525
Unknown CONFIG option! CONFIG_IP_ROUTE_PERVASIVE

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

--- linux-rdc-clean/net/ipv4/fib_semantics.c	2007-07-31 17:17:31.000000000 +0200
+++ linux-rdc/net/ipv4/fib_semantics.c	2007-07-31 18:22:54.000000000 +0200
@@ -522,10 +522,6 @@ static int fib_check_nh(struct fib_confi
 	if (nh->nh_gw) {
 		struct fib_result res;
 
-#ifdef CONFIG_IP_ROUTE_PERVASIVE
-		if (nh->nh_flags&RTNH_F_PERVASIVE)
-			return 0;
-#endif
 		if (nh->nh_flags&RTNH_F_ONLINK) {
 			struct net_device *dev;
 
