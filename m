From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: print skbedit action when dumping actions.
Date: Wed, 22 Mar 2017 14:00:31 -0400
Message-ID: <1490205631-16494-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:36638 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965391AbdCVSB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:01:27 -0400
Received: by mail-it0-f54.google.com with SMTP id w124so27969471itb.1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 11:01:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 tc/m_skbedit.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 8660d60..638715f 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -214,6 +214,8 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 			fprintf(f, " ptype %d", *ptype);
 	}
 
+	fprintf(f, " %s", action_n2a(p->action));
+
 	fprintf(f, "\n\t index %u ref %d bind %d",
 		p->index, p->refcnt, p->bindcnt);
 
-- 
1.9.1
