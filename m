From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: don't reject link-local nexthop on other
 interface
Date: Mon, 10 Aug 2015 13:29:47 -0700 (PDT)
Message-ID: <20150810.132947.858528788803489894.davem@davemloft.net>
References: <1438937668-12757-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793AbbHJU3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 16:29:47 -0400
In-Reply-To: <1438937668-12757-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri,  7 Aug 2015 10:54:28 +0200

> 48ed7b26faa7 ("ipv6: reject locally assigned nexthop addresses") is too
> strict; it rejects following corner-case:
> 
> ip -6 route add default via fe80::1:2:3 dev eth1
> 
> [ where fe80::1:2:3 is assigned to a local interface, but not eth1 ]
> 
> Fix this by restricting search to given device if nh is linklocal.
> 
> Joint work with Hannes Frederic Sowa.
> 
> Fixes: 48ed7b26faa7 ("ipv6: reject locally assigned nexthop addresses")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thank you.
