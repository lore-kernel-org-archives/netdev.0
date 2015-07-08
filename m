From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] iproute2: ipa: show switch id
Date: Wed,  8 Jul 2015 17:08:18 +0200
Message-ID: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34354 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbbGHPIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 11:08:22 -0400
Received: by wifm2 with SMTP id m2so92545870wif.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 08:08:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We forgot to include this patch somehow. So do it now.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 ip/ipaddress.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 85a81ba..b7b4e3e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -688,6 +688,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				      b1, sizeof(b1)));
 	}
 
+	if (tb[IFLA_PHYS_SWITCH_ID]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "switchid %s ",
+			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
+				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
+				      b1, sizeof(b1)));
+	}
+
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
-- 
1.9.3
