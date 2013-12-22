From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2] allow batch gets of actions
Date: Sun, 22 Dec 2013 10:33:13 -0500
Message-ID: <52B70639.60309@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040500000903080009070100"
To: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:39993 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab3LVPdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 10:33:17 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so5104422ieb.1
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 07:33:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040500000903080009070100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Attached.

cheers,
jamal

--------------040500000903080009070100
Content-Type: text/plain; charset=us-ascii;
 name="get-batch-action"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="get-batch-action"

commit c5f30cabef14c951596210b96bc9b423b0d39592
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Sun Dec 22 10:24:17 2013 -0500

    Allow batching of action gets
    Example:
    ----
    tc actions get \
    action gact index 100 \
    action gact index 4
    ----
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/m_action.c b/tc/m_action.c
index 4acabef..51085ec 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -144,6 +144,7 @@ new_cmd(char **argv)
 	if ((matches(*argv, "change") == 0) ||
 		(matches(*argv, "replace") == 0)||
 		(matches(*argv, "delete") == 0)||
+		(matches(*argv, "get") == 0)||
 		(matches(*argv, "add") == 0))
 			return 1;
 

--------------040500000903080009070100--
