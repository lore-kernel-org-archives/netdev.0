From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 36/38] netfilter: connlimit: use keyed locks
Date: Mon, 17 Mar 2014 15:26:44 +0100
Message-ID: <20140317142644.GB26584@breakpoint.cc>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
 <1395060178-11833-37-git-send-email-pablo@netfilter.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F6DF3E3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6DF3E3@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> wrote:
> From: Pablo Neira Ayuso
> > +#define CONNLIMIT_SLOTS	256
> > +#define CONNLIMIT_LOCK_SLOTS	32
> 
> You might want to make these explicitly unsigned to ensure
> the divisions are unsigned (so can be done with a simple mask).

I can do  this but I checked that at least on my machine gcc already
emits a 'add' instruction to reduce the hash value.
