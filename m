From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 36/38] netfilter: connlimit: use keyed locks
Date: Mon, 17 Mar 2014 14:40:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DF508@AcuExch.aculab.com>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
 <1395060178-11833-37-git-send-email-pablo@netfilter.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F6DF3E3@AcuExch.aculab.com>
 <20140317142644.GB26584@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Florian Westphal' <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140317142644.GB26584@breakpoint.cc>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal
> David Laight <David.Laight@ACULAB.COM> wrote:
> > From: Pablo Neira Ayuso
> > > +#define CONNLIMIT_SLOTS	256
> > > +#define CONNLIMIT_LOCK_SLOTS	32
> >
> > You might want to make these explicitly unsigned to ensure
> > the divisions are unsigned (so can be done with a simple mask).
> 
> I can do  this but I checked that at least on my machine gcc already
> emits a 'add' instruction to reduce the hash value.

I think you meant 'and' :-)
Yes the hash itself is probably unsigned so forces an unsigned modulus.
It just seemed better to force it from the other argument as well.

	David



