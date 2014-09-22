From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tcp: avoid possible arithmetic overflows
Date: Mon, 22 Sep 2014 16:27:03 -0400 (EDT)
Message-ID: <20140922.162703.824025819934075774.davem@davemloft.net>
References: <CAK6E8=d9y8D5we_fibzxstaXBMnQcOG3DsOAL0jhzDGK1H62cw@mail.gmail.com>
	<1411389739.26859.113.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411417184.26859.147.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, joe@perches.com, netdev@vger.kernel.org,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbaIVU1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:27:05 -0400
In-Reply-To: <1411417184.26859.147.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Sep 2014 13:19:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> icsk_rto is a 32bit field, and icsk_backoff can reach 15 by default,
> or more if some sysctl (eg tcp_retries2) are changed.
> 
> Better use 64bit to perform icsk_rto << icsk_backoff operations
> 
> As Joe Perches suggested, add a helper for this.
> 
> Yuchung spotted the tcp_v4_err() case.
> 
> From: Eric Dumazet <edumazet@google.com>

I assume you meant "Signed-off-by: " on that last line, not "From: " :-)

Applied,
