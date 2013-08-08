From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netfilter: add SYNPROXY core/target
Date: Thu, 8 Aug 2013 08:34:26 +0200
Message-ID: <20130808063425.GC24450@macbook.localnet>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
 <1375897371-18430-4-git-send-email-kaber@trash.net>
 <1375913514.4004.63.camel@edumazet-glaptop>
 <20130807233707.GA23937@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130807233707.GA23937@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 08, 2013 at 01:37:11AM +0200, Patrick McHardy wrote:
> On Wed, Aug 07, 2013 at 03:11:54PM -0700, Eric Dumazet wrote:
> > On Wed, 2013-08-07 at 19:42 +0200, Patrick McHardy wrote:
> > 
> > Also please check your uses of kfree_skb() .
> > 
> > Some of them would better be consume_skb() (for example in
> > ipv4_synproxy_hook())
> 
> I'll look into that.

Agreed for this case. The only other two kfree_skb()s are actually
error paths.
