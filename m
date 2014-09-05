From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] add help command to bonding master
Date: Fri,  5 Sep 2014 15:24:16 +0200
Message-ID: <1409923456-14596-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:50049 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaIENY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:24:28 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so816352wib.4
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:24:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 ip/iplink_bond.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index b5c511e..0a1ed03 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -339,6 +339,9 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 			}
 			ad_select = get_index(ad_select_tbl, *argv);
 			addattr8(n, 1024, IFLA_BOND_AD_SELECT, ad_select);
+		} else if (matches(*argv, "help") == 0) {
+			explain();
+			return -1;
 		} else {
 			fprintf(stderr, "bond: unknown command \"%s\"?\n", *argv);
 			explain();
-- 
1.9.3
