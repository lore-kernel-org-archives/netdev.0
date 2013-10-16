From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH: Iproute bridge] remove redundant check
Date: Wed, 16 Oct 2013 10:33:18 -0400
Message-ID: <525EA3AE.9020501@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030202090505030706020008"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:42093 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3JPOdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 10:33:22 -0400
Received: by mail-yh0-f46.google.com with SMTP id l109so176128yhq.19
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 07:33:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030202090505030706020008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


attached,

cheers,
jamal

--------------030202090505030706020008
Content-Type: text/plain; charset=us-ascii;
 name="patch-simp1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-simp1"

commit 355c2d4679e81c1e1c2ae12e03b6a2ced5ebb7d0
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Wed Oct 16 10:30:01 2013 -0400

    [Iproute: bridge] Remove redundant check
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/bridge/link.c b/bridge/link.c
index 38dfaea..ab4a5d5 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -271,7 +271,7 @@ static int brlink_modify(int argc, char **argv)
 				exit(-1);
 		} else if (strcmp(*argv, "hairpin") == 0) {
 			NEXT_ARG();
-			if (!on_off("hairping", &hairpin, *argv))
+			if (!on_off("hairpin", &hairpin, *argv))
 				exit(-1);
 		} else if (strcmp(*argv, "fastleave") == 0) {
 			NEXT_ARG();
@@ -357,9 +357,7 @@ static int brlink_modify(int argc, char **argv)
 		nest = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
 
 		addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
-
-		if (mode >= 0)
-			addattr16(&req.n, sizeof(req), IFLA_BRIDGE_MODE, mode);
+		addattr16(&req.n, sizeof(req), IFLA_BRIDGE_MODE, mode);
 
 		addattr_nest_end(&req.n, nest);
 	}

--------------030202090505030706020008--
