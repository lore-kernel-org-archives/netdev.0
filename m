From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 10/21] netfilter: ipset: Return bool values instead of int
Date: Mon, 18 May 2015 18:52:55 +0200
Message-ID: <20150518165255.GA5035@salvia>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
 <1431966324-4494-11-git-send-email-pablo@netfilter.org>
 <1431966690.2870.27.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Popovich <popovich_sergei@mail.ua>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431966690.2870.27.camel@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 18, 2015 at 09:31:30AM -0700, Joe Perches wrote:
> On Mon, 2015-05-18 at 18:25 +0200, Pablo Neira Ayuso wrote:
> > From: Sergey Popovich <popovich_sergei@mail.ua>
> []
> > diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
> []
> > @@ -56,15 +56,15 @@ hash_ip4_data_equal(const struct hash_ip4_elem *e1,
> >  	return e1->ip == e2->ip;
> >  }
> >  
> > -static inline bool
> > +static bool
> 
> It's nicer when a change like this, which doesn't fit the
> subject description, is explained or described in the commit log.

I indicated this in the patchset description:

"10) Return true/false instead of 0/1 in functions that return boolean
     in the ipset code."

but I agree that this should show in the description as well to make
this self-contained.

I'll put a closer look on this next time, sorry.
