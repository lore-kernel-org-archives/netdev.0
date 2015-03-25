From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix ipv4 mapped request socks
Date: Wed, 25 Mar 2015 00:57:38 -0400 (EDT)
Message-ID: <20150325.005738.199321600853824869.davem@davemloft.net>
References: <1427258756.25985.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbbCYE5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 00:57:40 -0400
In-Reply-To: <1427258756.25985.104.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Mar 2015 21:45:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ss should display ipv4 mapped request sockets like this :
> 
> tcp    SYN-RECV   0      0  ::ffff:192.168.0.1:8080   ::ffff:192.0.2.1:35261 
> 
> and not like this :
> 
> tcp    SYN-RECV   0      0  192.168.0.1:8080   192.0.2.1:35261 
> 
> We should init ireq->ireq_family based on listener sk_family,
> not the actual protocol carried by SYN packet.
> 
> This means we can set ireq_family in inet_reqsk_alloc()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 3f66b083a5b7 ("inet: introduce ireq_family")

Applied, thanks Eric.

Please put the Fixes: tag before all the signoffs and acks
in the future, thanks in advance.
