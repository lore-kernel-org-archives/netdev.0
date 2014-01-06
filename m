From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 02/13] netfilter: xt_NFQUEUE: separate reusable code
Date: Mon, 6 Jan 2014 15:02:21 +0100
Message-ID: <20140106140221.GI28854@breakpoint.cc>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
 <1389016002-9116-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389016002-9116-3-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> From: Eric Leblond <eric@regit.org>
> 
> This patch prepares the addition of nft_queue module by moving
> reusable code into a header file.
> 
> This patch also converts NFQUEUE to use prandom_u32 to initialize
> the random jhash seed as suggested by Florian Westphal.

Pre-emptive explanation: prandom_u32 is ok because this hash is
only used to decide on which queue the packet should be enqueued to.
