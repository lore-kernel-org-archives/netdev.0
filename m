From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 3/9] ife: improve help text
Date: Sat,  1 Oct 2016 16:48:31 -0400
Message-ID: <1475354917-7912-4-git-send-email-jhs@emojatatu.com>
References: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34487 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751914AbcJAUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:49:16 -0400
Received: by mail-pf0-f194.google.com with SMTP id 190so713594pfv.1
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:48:52 -0700 (PDT)
In-Reply-To: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_ife.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index 588bad7..862461b 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -29,12 +29,13 @@
 static void ife_explain(void)
 {
 	fprintf(stderr,
-		"Usage:... ife {decode|encode} {ALLOW|USE} [dst DMAC] [src SMAC] [type TYPE] [CONTROL] [index INDEX]\n");
+		"Usage:... ife {decode|encode} [{ALLOW|USE} ATTR] [dst DMAC] [src SMAC] [type TYPE] [CONTROL] [index INDEX]\n");
 	fprintf(stderr,
 		"\tALLOW := Encode direction. Allows encoding specified metadata\n"
 		"\t\t e.g \"allow mark\"\n"
 		"\tUSE := Encode direction. Enforce Static encoding of specified metadata\n"
 		"\t\t e.g \"use mark 0x12\"\n"
+		"\tATTR := mark (32-bit), prio (32-bit), tcindex (16-bit)\n"
 		"\tDMAC := 6 byte Destination MAC address to encode\n"
 		"\tSMAC := optional 6 byte Source MAC address to encode\n"
 		"\tTYPE := optional 16 bit ethertype to encode\n"
-- 
1.9.1
