From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC net-next PATCH V1 5/9] net: frag per CPU mem limit and LRU
 list accounting
Date: Mon, 26 Nov 2012 10:54:20 +0800
Message-ID: <1353898460.11282.2.camel@cr0>
References: <20121123130749.18764.25962.stgit@dragon>
	 <20121123130826.18764.66507.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649Ab2KZC4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 21:56:12 -0500
In-Reply-To: <20121123130826.18764.66507.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-23 at 14:08 +0100, Jesper Dangaard Brouer wrote:
> +       // QUESTION: Please advice in a better alloc solution than
> NR_CPUS
> +       struct cpu_resource     percpu[NR_CPUS]; 

alloc_percpu(struct cpu_resource) ?

BTW, struct cpu_resource is not a good name here, it is too generic.
