From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: trivial: Remove nocache argument from
 tcp_v4_send_synack
Date: Tue, 20 Aug 2013 15:07:48 -0700 (PDT)
Message-ID: <20130820.150748.951759374492185487.davem@davemloft.net>
References: <1376840078-6556-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab3HTWHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 18:07:48 -0400
In-Reply-To: <1376840078-6556-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Sun, 18 Aug 2013 17:34:38 +0200

> The nocache-argument was used in tcp_v4_send_synack as an argument to
> inet_csk_route_req. However, since ba3f7f04ef2b (ipv4: Kill
> FLOWI_FLAG_RT_NOCACHE and associated code.) this is no more used.
> 
> This patch removes the unsued argument from tcp_v4_send_synack.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied.
