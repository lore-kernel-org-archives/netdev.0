From: David Miller <davem@davemloft.net>
Subject: Re: [BISECTED] Linux 3.2: Networking out of LAN does not work
Date: Wed, 25 Jan 2012 21:41:46 -0500 (EST)
Message-ID: <20120125.214146.1725158231070595211.davem@davemloft.net>
References: <OF0BD4E9BA.3C3D7E41-ONC1257990.0034993D-C1257990.0034B2CE@bdpnet.dk>
	<1327484459.2425.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1327489531.2425.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rum@bankdata.dk, netdev@vger.kernel.org, mihai.maruseac@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab2AZCmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 21:42:10 -0500
In-Reply-To: <1327489531.2425.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2012 12:05:31 +0100

> OK please test the following patch.
> 
> [PATCH] net: use index hash for /proc/net/dev

Sorry, we never promised to list devices in any particular order,
any such dependency is a bug and must be fixed instead of papered
around by the kernel.

This same issue came up for routes too once we deleted fib_hash
and fib_trie listed them in a different order.

I'm not applying this.
