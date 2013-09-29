From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH]: iproute action: typo nat fix
Date: Sun, 29 Sep 2013 07:39:23 -0400
Message-ID: <5248116B.7080305@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000807070700040304010700"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	herbert@gondor.apana.org.au
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:45992 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab3I2Lj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 07:39:26 -0400
Received: by mail-ie0-f177.google.com with SMTP id qd12so7786204ieb.36
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 04:39:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000807070700040304010700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


attached.

cheers,
jamal

--------------000807070700040304010700
Content-Type: text/plain; charset=UTF-8;
 name="nat-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nat-1"

commit 012b8c4b3af629039d2bb47ade6e0d3e6980a72b
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Sun Sep 29 07:35:21 2013 -0400

    If you taketh you giveth.
    I Went the LinuxWay and copied this for m_simple.c and noticed
    this one typo (I wonder where it came from?;->).
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/m_nat.c b/tc/m_nat.c
index 01ec032..d502a81 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -146,7 +146,7 @@ parse_nat(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct
 		if (matches(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&sel.index, *argv, 10)) {
-				fprintf(stderr, "Pedit: Illegal \"index\"\n");
+				fprintf(stderr, "Nat: Illegal \"index\"\n");
 				return -1;
 			}
 			argc--;

--------------000807070700040304010700--
