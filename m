From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2] iplink: bond_slave: fix ad_actor/partner_oper_port_state output
Date: Mon,  8 Feb 2016 17:13:58 +0100
Message-ID: <1454948038-1090-1-git-send-email-razor@blackwall.org>
Cc: stannous@cumulusnetworks.com, roopa@cumulusnetworks.com,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33262 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbcBHQOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 11:14:10 -0500
Received: by mail-wm0-f47.google.com with SMTP id g62so139540513wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 08:14:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

It seems that I've made a mistake when I exported these, instead of a
space in the end I've put a newline character which is wrong and breaks
the single line output.

Fixes: 7d6bc3b87abad ("bonding: export 3ad actor and partner port state")
Reported-by: Sam Tannous <stannous@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bond_slave.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index 9b569b1daa4e..2f3364ee45a5 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -80,11 +80,11 @@ static void bond_slave_print_opt(struct link_util *lu, FILE *f, struct rtattr *t
 			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_AGGREGATOR_ID]));
 
 	if (tb[IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE])
-		fprintf(f, "ad_actor_oper_port_state %d\n",
+		fprintf(f, "ad_actor_oper_port_state %d ",
 			rta_getattr_u8(tb[IFLA_BOND_SLAVE_AD_ACTOR_OPER_PORT_STATE]));
 
 	if (tb[IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE])
-		fprintf(f, "ad_partner_oper_port_state %d\n",
+		fprintf(f, "ad_partner_oper_port_state %d ",
 			rta_getattr_u16(tb[IFLA_BOND_SLAVE_AD_PARTNER_OPER_PORT_STATE]));
 }
 
-- 
2.4.3
