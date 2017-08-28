From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH iproute2 2/4] tc: m_ife: print IEEE ethertype format
Date: Mon, 28 Aug 2017 15:07:36 -0400
Message-ID: <20170828190738.26829-3-aring@mojatatu.com>
References: <20170828190738.26829-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36231 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751597AbdH1TIs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:08:48 -0400
Received: by mail-io0-f196.google.com with SMTP id v96so1097070ioi.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:08:48 -0700 (PDT)
In-Reply-To: <20170828190738.26829-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses the usually IEEE format to display an ethertype which is
4-digits and every digit in upper case.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 tc/m_ife.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index e05e2276..7b57130e 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -125,7 +125,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 			NEXT_ARG();
 			if (get_u16(&ife_type, *argv, 0))
 				invarg("ife type is invalid", *argv);
-			fprintf(stderr, "IFE type 0x%x\n", ife_type);
+			fprintf(stderr, "IFE type 0x%04X\n", ife_type);
 			user_type = 1;
 		} else if (matches(*argv, "dst") == 0) {
 			NEXT_ARG();
-- 
2.11.0
