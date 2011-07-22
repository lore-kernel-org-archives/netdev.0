From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Thu, 21 Jul 2011 21:26:16 -0700 (PDT)
Message-ID: <20110721.212616.1138861523109414324.davem@davemloft.net>
References: <1311082696.2375.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1311089463.2375.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1311108423.3113.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fernando@gont.com.ar, security@kernel.org, eugeneteo@kernel.sg,
	netdev@vger.kernel.org, mpm@selenic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792Ab1GVE1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:27:03 -0400
In-Reply-To: <1311108423.3113.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Jul 2011 22:47:03 +0200

> IPv6 fragment identification generation is way beyond what we use for
> IPv4 : It uses a single generator. Its not scalable and allows DOS
> attacks.
> 
> Now inetpeer is IPv6 aware, we can use it to provide a more secure and
> scalable frag ident generator (per destination, instead of system wide)
> 
> This patch :
> 1) defines a new secure_ipv6_id() helper
> 2) extends inet_getid() to provide 32bit results
> 3) extends ipv6_select_ident() with a new dest parameter
> 
> Reported-by: Fernando Gont <fernando@gont.com.ar>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Eugene Teo <eugeneteo@kernel.sg>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, and I'll queue up your backport-friendly version for -stable.
