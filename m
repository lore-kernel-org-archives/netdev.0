From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] tcp: fix inet6_csk_route_req() for
 link-local addresses
Date: Thu, 28 Jun 2012 17:55:19 -0700 (PDT)
Message-ID: <20120628.175519.1988106239175790983.davem@davemloft.net>
References: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786Ab2F2AzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 20:55:19 -0400
In-Reply-To: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 28 Jun 2012 15:34:18 -0700

> Fix inet6_csk_route_req() to use as the flowi6_oif the treq->iif,
> which is correctly fixed up in tcp_v6_conn_request() to handle the
> case of link-local addresses. This brings it in line with the
> tcp_v6_send_synack() code, which is already correctly using the
> treq->iif in this way.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
