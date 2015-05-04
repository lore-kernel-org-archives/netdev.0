From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon, 4 May 2015 13:05:08 -0700
Message-ID: <20150504200506.GA14604@Alexeis-MacBook-Pro.local>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
 <20150504155639.GA14367@Alexeis-MBP.westell.com>
 <20150504161956.GK22481@breakpoint.cc>
 <5547AA9C.3030300@mojatatu.com>
 <20150504174358.GN22481@breakpoint.cc>
 <5547BEC4.4090400@mojatatu.com>
 <20150504185941.GA17061@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150504185941.GA17061@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2015 at 08:59:41PM +0200, Florian Westphal wrote:

> At the moment I think having two hooks provides no advantage, it only
> complicates code.

It's exactly the opposite which this thread is showing.
Single hook creates complicated relationship between tc/nft.
There is no code shared. TC critical path becomes slower with
extra dereference and indirect jump. We have to think how
'tc qdisc add ingress' can auto-unload nft_ingress, etc
That is real complexity that can be avoided with two hooks.

