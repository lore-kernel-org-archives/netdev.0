From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] ss: initialize 'fackets' member of tcpstat structure
Date: Wed, 18 Oct 2017 15:44:01 -0400
Message-ID: <1508355841-24131-1-git-send-email-mrv@mojatatu.com>
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:43472 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdJRToK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 15:44:10 -0400
Received: by mail-io0-f194.google.com with SMTP id 134so7493497ioo.0
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 12:44:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'fackets' has never been initialized with kernel extracted information, thus
never really printed.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 misc/ss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/misc/ss.c b/misc/ss.c
index 09bff8a..465e867 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2226,6 +2226,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.retrans_total  = info->tcpi_total_retrans;
 		s.lost		 = info->tcpi_lost;
 		s.sacked	 = info->tcpi_sacked;
+		s.fackets	 = info->tcpi_fackets;
 		s.reordering	 = info->tcpi_reordering;
 		s.rcv_space	 = info->tcpi_rcv_space;
 		s.cwnd		 = info->tcpi_snd_cwnd;
-- 
1.9.1
