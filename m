From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix TCP_MAXSEG for established IPv6 passive
 sockets
Date: Sun, 22 Apr 2012 17:10:16 -0400 (EDT)
Message-ID: <20120422.171016.2000807309124070108.davem@davemloft.net>
References: <1335123947-9906-1-git-send-email-ncardwell@google.com>
	<1335125694.2395.277.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, edumazet@google.com,
	nanditad@google.com, ycheng@google.com, ilpo.jarvinen@helsinki.fi,
	maze@google.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964Ab2DVVK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 17:10:28 -0400
In-Reply-To: <1335125694.2395.277.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 22 Apr 2012 22:14:54 +0200

> On Sun, 2012-04-22 at 15:45 -0400, Neal Cardwell wrote:
>> Commit f5fff5d forgot to fix TCP_MAXSEG behavior IPv6 sockets, so IPv6
>> TCP server sockets that used TCP_MAXSEG would find that the advmss of
>> child sockets would be incorrect. This commit mirrors the advmss logic
>> from tcp_v4_syn_recv_sock in tcp_v6_syn_recv_sock. Eventually this
>> logic should probably be shared between IPv4 and IPv6, but this at
>> least fixes this issue.
>> 
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
