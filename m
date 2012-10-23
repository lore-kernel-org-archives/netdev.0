From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: tcp: clean up tcp_v6_early_demux() icsk
 variable
Date: Tue, 23 Oct 2012 13:03:56 -0400 (EDT)
Message-ID: <20121023.130356.708652579929045187.davem@davemloft.net>
References: <1350978108.8609.1542.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757243Ab2JWREB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:04:01 -0400
In-Reply-To: <1350978108.8609.1542.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Oct 2012 09:41:48 +0200

> From: Neal Cardwell <ncardwell@google.com>
> 
> Remove an icsk variable, which by convention should refer to an
> inet_connection_sock rather than an inet_sock. In the process, make
> the tcp_v6_early_demux() code and formatting a bit more like
> tcp_v4_early_demux(), to ease comparisons and maintenance.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
