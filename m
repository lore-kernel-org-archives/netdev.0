From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: restore fastopen operations
Date: Mon, 05 Oct 2015 03:19:37 -0700 (PDT)
Message-ID: <20151005.031937.93165702217725447.davem@davemloft.net>
References: <1443619103.32531.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbJEKD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:03:57 -0400
In-Reply-To: <1443619103.32531.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Sep 2015 06:18:23 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I accidentally cleared fastopenq.max_qlen in reqsk_queue_alloc()
> while max_qlen can be set before listen() is called,
> using TCP_FASTOPEN socket option for example.
> 
> Fixes: 0536fcc039a8 ("tcp: prepare fastopen code for upcoming listener changes")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
