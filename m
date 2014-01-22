From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: metrics: Handle v6/v4-mapped sockets in
 tcp-metrics
Date: Tue, 21 Jan 2014 23:09:56 -0800 (PST)
Message-ID: <20140121.230956.767376113999056606.davem@davemloft.net>
References: <1390288632-28729-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbaAVHJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:09:57 -0500
In-Reply-To: <1390288632-28729-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Tue, 21 Jan 2014 08:17:12 +0100

> A socket may be v6/v4-mapped. In that case sk->sk_family is AF_INET6,
> but the IP being used is actually an IPv4-address.
> Current's tcp-metrics will thus represent it as an IPv6-address:
> 
> root@server:~# ip tcp_metrics
> ::ffff:10.1.1.2 age 22.920sec rtt 18750us rttvar 15000us cwnd 10
> 10.1.1.2 age 47.970sec rtt 16250us rttvar 10000us cwnd 10
> 
> This patch modifies the tcp-metrics so that they are able to handle the
> v6/v4-mapped sockets correctly.
> 
> Fixes: 51c5d0c4b169b (tcp: Maintain dynamic metrics in local cache.)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Please respin this against net-next, thanks.
