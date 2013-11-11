From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [patch iproute2] ipaddress: add a black line for each device to make the output more readable
Date: Mon, 11 Nov 2013 23:03:30 +0800
Message-ID: <1384182210-8901-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:55869 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab3KKPDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:03:49 -0500
Received: by mail-pd0-f176.google.com with SMTP id g10so5311434pdj.21
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 07:03:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we have multi links, the output huddled together and make it hard to read.
Let's use the old ifconfig output style.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/ipaddress.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1c3e4da..9570f16 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -782,6 +782,7 @@ static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *
 
 		print_addrinfo(NULL, n, fp);
 	}
+	fprintf(fp, "\n");
 	return 0;
 }
 
-- 
1.8.1.4
