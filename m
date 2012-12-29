From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sctp: make sctp_addr_wq_timeout_handler static
Date: Fri, 28 Dec 2012 20:18:55 -0800
Message-ID: <20121228201855.4275db64@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51757 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab2L2EUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 23:20:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix sparse warning about local function that should be static.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sctp/protocol.c	2012-12-27 11:36:34.817072247 -0800
+++ b/net/sctp/protocol.c	2012-12-28 20:02:51.445778974 -0800
@@ -595,7 +595,7 @@ static void sctp_v4_ecn_capable(struct s
 	INET_ECN_xmit(sk);
 }
 
-void sctp_addr_wq_timeout_handler(unsigned long arg)
+static void sctp_addr_wq_timeout_handler(unsigned long arg)
 {
 	struct net *net = (struct net *)arg;
 	struct sctp_sockaddr_entry *addrw, *temp;
