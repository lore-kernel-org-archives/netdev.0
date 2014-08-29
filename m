From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/5] tcp: silence useless debug message
Date: Fri, 29 Aug 2014 00:09:20 -0700
Message-ID: <20140829071029.906865956@networkplumber.org>
References: <20140829070918.508987897@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:46824 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaH2HKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:10:32 -0400
Received: by mail-pa0-f45.google.com with SMTP id bj1so5834820pad.4
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:10:31 -0700 (PDT)
Content-Disposition: inline; filename=tcp-nomsg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message isn't really needed.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv4/tcp_cong.c	2014-05-05 23:44:19.000000000 -0700
+++ b/net/ipv4/tcp_cong.c	2014-08-22 06:33:06.067542809 -0700
@@ -51,7 +51,7 @@ int tcp_register_congestion_control(stru
 		ret = -EEXIST;
 	} else {
 		list_add_tail_rcu(&ca->list, &tcp_cong_list);
-		pr_info("%s registered\n", ca->name);
+		pr_debug("%s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
 
