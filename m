From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC net-next PATCH V1 1/9] net: frag evictor, avoid killing
 warm frag queues
Date: Fri, 23 Nov 2012 20:58:15 +0100
Message-ID: <20121123195815.GA32625@breakpoint.cc>
References: <20121123130749.18764.25962.stgit@dragon>
 <20121123130806.18764.41854.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41600 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751448Ab2KWT60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 14:58:26 -0500
Content-Disposition: inline
In-Reply-To: <20121123130806.18764.41854.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> +// TODO: Idea what about also looking at flag INET_FRAG_FIRST_IN
> +// just as safe-guard against frags with a dropped "head" packet
> +		if (!force && q->creation_ts == (u32) jiffies) {

I think we should not rely on head fragment arriving first.
