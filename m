From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] tcp: use inet6_csk_route_req() in
 tcp_v6_send_synack()
Date: Thu, 28 Jun 2012 17:55:32 -0700 (PDT)
Message-ID: <20120628.175532.672427564547677756.davem@davemloft.net>
References: <1340922861-11684-1-git-send-email-ncardwell@google.com>
	<1340922861-11684-3-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab2F2Azd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 20:55:33 -0400
In-Reply-To: <1340922861-11684-3-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 28 Jun 2012 15:34:20 -0700

> With the recent change (earlier in this patch series) to set
> flowi6_oif to treq->iif in inet6_csk_route_req(), the dst lookup in
> these two functions is now identical, so tcp_v6_send_synack() can now
> just call inet6_csk_route_req(), to reduce code duplication and keep
> things closer to the IPv4 side, which is structured this way.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
