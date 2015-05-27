From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Tue, 26 May 2015 23:52:52 -0400 (EDT)
Message-ID: <20150526.235252.1950980875679896021.davem@davemloft.net>
References: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbbE0Dw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 23:52:56 -0400
In-Reply-To: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 May 2015 08:55:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> By making sure sk->sk_gso_max_segs minimal value is one,
> and sysctl_tcp_min_tso_segs minimal value is one as well,
> tcp_tso_autosize() will return a non zero value.
> 
> We can then revert 843925f33fcc293d80acf2c5c8a78adf3344d49b
> ("tcp: Do not apply TSO segment limit to non-TSO packets")
> and save few cpu cycles in fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
