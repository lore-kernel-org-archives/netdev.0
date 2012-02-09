From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] netfilter: nf_queue: fix queueing of bridged gro
 skbs
Date: Thu, 09 Feb 2012 13:44:38 -0500 (EST)
Message-ID: <20120209.134438.528614070160508984.davem@davemloft.net>
References: <1328530990-6782-1-git-send-email-fw@strlen.de>
	<20120209154421.GA5865@1984>
	<20120209163701.GB14772@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120209163701.GB14772@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Thu, 9 Feb 2012 17:37:01 +0100

> It treats skb->data as the starting point of the
> segmentation, so I think its the callers job to make skb->data
> point at the right place (network header, mac header, ...)

Right.
