From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: add a schedule point in
 inet_twsk_purge()
Date: Wed, 18 Mar 2015 22:39:09 -0400 (EDT)
Message-ID: <20150318.223909.1377505203437717082.davem@davemloft.net>
References: <1426725651.25985.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbCSCjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:39:10 -0400
In-Reply-To: <1426725651.25985.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Mar 2015 17:40:51 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> On a large hash table, we can easily spend seconds to
> walk over all entries. Add a cond_resched() to yield
> cpu if necessary.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Yeah this has always been a sore spot, at least it runs in
process context these days.

Applied, thanks Eric.
