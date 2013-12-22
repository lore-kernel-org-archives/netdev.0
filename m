From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2] simple print newline
Date: Sun, 22 Dec 2013 07:50:09 -0500
Message-ID: <52B6E001.60305@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020303010504040506010505"
To: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:48528 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab3LVMuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 07:50:12 -0500
Received: by mail-ig0-f173.google.com with SMTP id uq10so19123399igb.0
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 04:50:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020303010504040506010505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


attached.

cheers,
jamal

--------------020303010504040506010505
Content-Type: text/plain; charset=us-ascii;
 name="simp2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="simp2"

commit d7869e6167c3553e93e254940b0647032b40fed8
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Sun Dec 22 07:46:28 2013 -0500

    print new line at the end for aesthetics
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/m_simple.c b/tc/m_simple.c
index 0224440..a8e1d6b 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -188,9 +188,9 @@ static int print_simple(struct action_util *au, FILE * f, struct rtattr *arg)
 		if (tb[TCA_DEF_TM]) {
 			struct tcf_t *tm = RTA_DATA(tb[TCA_DEF_TM]);
 			print_tm(f, tm);
-			fprintf(f, "\n");
 		}
 	}
+	fprintf(f, "\n");
 
 	return 0;
 }

--------------020303010504040506010505--
