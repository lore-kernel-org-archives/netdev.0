From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: nf_queue: fix queueing of bridged gro
 skbs
Date: Thu, 9 Feb 2012 20:37:25 +0100
Message-ID: <20120209193725.GA6881@1984>
References: <1328530990-6782-1-git-send-email-fw@strlen.de>
 <20120209154421.GA5865@1984>
 <20120209163701.GB14772@Chamillionaire.breakpoint.cc>
 <20120209.134438.528614070160508984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120209.134438.528614070160508984.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 09, 2012 at 01:44:38PM -0500, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Thu, 9 Feb 2012 17:37:01 +0100
> 
> > It treats skb->data as the starting point of the
> > segmentation, so I think its the callers job to make skb->data
> > point at the right place (network header, mac header, ...)
> 
> Right.

OK, I'll take the patch for nf_queue then. Thanks!
