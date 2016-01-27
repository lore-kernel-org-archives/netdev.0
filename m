From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: early demux should be aware of fragments
Date: Wed, 27 Jan 2016 17:02:03 -0500 (EST)
Message-ID: <20160127.170203.701586924097928864.davem@davemloft.net>
References: <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
	<1453787905.11327.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<1453856382.11327.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@ovn.org, netdev@vger.kernel.org, fw@strlen.de,
	hannes@stressinduktion.org, pshelar@ovn.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968518AbcA0WCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 17:02:08 -0500
In-Reply-To: <1453856382.11327.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Jan 2016 16:59:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We should not assume a valid protocol header is present,
> as this is not the case for IPv4 fragments.
> 
> Lets avoid extra cache line misses and potential bugs
> if we actually find a socket and incorrectly uses its dst.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
