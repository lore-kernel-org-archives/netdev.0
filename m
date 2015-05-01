From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: speedup ip_idents_reserve()
Date: Fri, 01 May 2015 19:44:13 -0400 (EDT)
Message-ID: <20150501.194413.195074972640434346.davem@davemloft.net>
References: <1430501869.3711.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbbEAXoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 19:44:16 -0400
In-Reply-To: <1430501869.3711.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 May 2015 10:37:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Under stress, ip_idents_reserve() is accessing a contended
> cache line twice, with non optimal MESI transactions.
> 
> If we place timestamps in separate location, we reduce this
> pressure by ~50% and allow atomic_add_return() to issue
> a Request for Ownership.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
