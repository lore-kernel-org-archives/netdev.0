From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 4/5] team: make local function static
Date: Fri, 08 Mar 2013 11:07:43 -0800
Message-ID: <20130308190809.432176649@vyatta.com>
References: <20130308190739.260966567@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:37274 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab3CHTX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 14:23:28 -0500
Content-Disposition: inline; filename=team-static.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/team/team.c	2013-03-06 15:30:50.195924953 -0800
+++ b/drivers/net/team/team.c	2013-03-08 10:34:45.446144458 -0800
@@ -503,9 +503,9 @@ static bool team_dummy_transmit(struct t
 	return false;
 }
 
-rx_handler_result_t team_dummy_receive(struct team *team,
-				       struct team_port *port,
-				       struct sk_buff *skb)
+static rx_handler_result_t team_dummy_receive(struct team *team,
+					      struct team_port *port,
+					      struct sk_buff *skb)
 {
 	return RX_HANDLER_ANOTHER;
 }
