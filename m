From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: make br_parse_ip_options  static
Date: Mon, 18 Oct 2010 17:03:21 -0700
Message-ID: <20101018170321.2b0de4ea@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57574 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932927Ab0JSADY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 20:03:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_netfilter.c	2010-10-18 17:01:36.903364885 -0700
+++ b/net/bridge/br_netfilter.c	2010-10-18 17:01:48.106569141 -0700
@@ -213,7 +213,7 @@ static inline void nf_bridge_update_prot
  * expected format
  */
 
-int br_parse_ip_options(struct sk_buff *skb)
+static int br_parse_ip_options(struct sk_buff *skb)
 {
 	struct ip_options *opt;
 	struct iphdr *iph;

