From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ipvs: fix dst leak in
 __ip_vs_addr_is_local_v6
Date: Mon, 25 Jun 2012 15:11:30 +0200
Message-ID: <20120625131130.GB12597@1984>
References: <1340611103.10893.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55906 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756413Ab2FYNLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 09:11:36 -0400
Content-Disposition: inline
In-Reply-To: <1340611103.10893.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 25, 2012 at 09:58:23AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> After call to ip6_route_output() we must release dst or we leak it.
> 
> Also should test dst->error, as ip6_route_output() never returns NULL.
> 
> Use boolean while we are at it.

Applied, thanks Eric.
