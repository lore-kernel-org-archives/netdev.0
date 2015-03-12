From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 nf-next 3/6] netfilter: bridge: use skb->cb to track
 otherhost mangling
Date: Thu, 12 Mar 2015 19:35:03 +0100
Message-ID: <20150312183503.GB12169@breakpoint.cc>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
 <1426179925-18220-4-git-send-email-fw@strlen.de>
 <5501D498.4050003@hartkopp.net>
 <20150312183113.GA12169@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eyal Birger <eyal.birger@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150312183113.GA12169@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal <fw@strlen.de> wrote:
> > > +	BUILD_BUG_ON(sizeof(struct nf_bridge_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
> > > +
> > 
> > Please use sock_skb_cb_check_size(size) for cb size checking which is the
> > 'new' check for cb sizes for netdev.
> 
> I can do this for conistency, but its technically not needed here.

I take that back, it would actually be inconsistent to use
sock_skb_cb_check_size since nf_bridge skbs will not be associated with
sockets.
