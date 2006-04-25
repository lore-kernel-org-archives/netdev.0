From: Hua Zhong <hzhong@gmail.com>
Subject: FIXED Re: [PATCH] remove likely in ip_rcv_finish()
Date: Tue, 25 Apr 2006 02:20:16 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0604250218470.4491@localhost.localdomain>
References: <Pine.LNX.4.64.0604250204470.4481@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from wproxy.gmail.com ([64.233.184.233]:59301 "EHLO wproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932161AbWDYJVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 05:21:48 -0400
Received: by wproxy.gmail.com with SMTP id i30so1029946wra
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 02:21:47 -0700 (PDT)
To: davem@davemloft.net, netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0604250204470.4481@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Horrible typo! I really should have gone to sleep now.

Correct patch attached.

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 18d7fad..c9026db 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -337,7 +337,7 @@ static inline int ip_rcv_finish(struct s
  	 *	Initialise the virtual path cache for the packet. It describes
  	 *	how the packet travels inside Linux networking.
  	 */ 
-	if (likely(skb->dst == NULL)) {
+	if (skb->dst == NULL) {
  		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
  					 skb->dev);
  		if (unlikely(err)) {
