From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 7/7] ss: Fixed wrong tcp ato value from netlink
Date: Fri, 13 Feb 2015 22:14:04 +0200
Message-ID: <1423858444-10158-8-git-send-email-vadim4j@gmail.com>
References: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:35139 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbbBMUZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 15:25:19 -0500
Received: by labgm9 with SMTP id gm9so18753609lab.2
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:25:17 -0800 (PST)
In-Reply-To: <1423858444-10158-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 9cf0055..69794ea 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1903,7 +1903,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.backoff	 = info->tcpi_backoff;
 		s.rtt		 = (double)info->tcpi_rtt / 1000;
 		s.rttvar	 = (double)info->tcpi_rttvar / 1000;
-		s.ato		 = (double)info->tcpi_rttvar / 1000;
+		s.ato		 = (double)info->tcpi_ato / 1000;
 		s.mss		 = info->tcpi_snd_mss;
 		s.rcv_space	 = info->tcpi_rcv_space;
 		s.rcv_rtt	 = (double)info->tcpi_rcv_rtt / 1000;
-- 
2.2.2
