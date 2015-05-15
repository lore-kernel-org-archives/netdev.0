From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: synproxy: fix sparse errors
Date: Fri, 15 May 2015 20:05:29 +0200
Message-ID: <20150515180529.GA3446@salvia>
References: <1431706051.27831.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57534 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754846AbbEOSAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 14:00:45 -0400
Content-Disposition: inline
In-Reply-To: <1431706051.27831.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 09:07:31AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Fix verbose sparse errors :
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/netfilter/ipt_SYNPROXY.o
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks Eric.

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

> ---
> Trivial errors, please David merge this directly into your tree.
