From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] sock: relax WARN_ON() in
 sock_owned_by_user()
Date: Mon, 25 Apr 2016 11:50:06 -0400 (EDT)
Message-ID: <20160425.115006.523247588174639447.davem@davemloft.net>
References: <176911.1461527778@turing-police.cc.vt.edu>
	<1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
	<1461591249.5535.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbcDYPuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 11:50:12 -0400
In-Reply-To: <1461591249.5535.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Apr 2016 06:34:09 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Valdis reported tons of stack dumps caused by WARN_ON() in
> sock_owned_by_user()
> 
> This test needs to be relaxed if/when lockdep disables itself.
> 
> Note that other lockdep_sock_is_held() callers are all from
> rcu_dereference_protected() sections which already are disabled
> if/when lockdep has been disabled.
> 
> Fixes: fafc4e1ea1a4 ("sock: tigthen lockdep checks for sock_owned_by_user")
> Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Eric.
