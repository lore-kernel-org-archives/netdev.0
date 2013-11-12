From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux-next: manual merge of the random tree with the net-next tree
Date: Wed, 13 Nov 2013 00:13:32 +0100
Message-ID: <20131112231332.GH14929@order.stressinduktion.org>
References: <20131112155549.c160273993147244ed6bc81d@canb.auug.org.au> <5281ED01.5020204@redhat.com> <20131112230242.GA1643@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Theodore Ts'o <tytso@mit.edu>,
	Daniel Borkmann <dborkman@redhat.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131112230242.GA1643@thunk.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 06:02:42PM -0500, Theodore Ts'o wrote:
> On Tue, Nov 12, 2013 at 09:55:29AM +0100, Daniel Borkmann wrote:
> > 
> > As per Hannes' suggestion, the result should look like (see cover
> > letter in [1]):
> > 
> > if (r->entropy_total > 128) {
> > 	r->initialized = 1;
> > 	r->entropy_total = 0;
> > 	if (r == &nonblocking_pool) {
> > 		prandom_reseed_late();
> > 		pr_notice("random: %s pool is initialized\n",
> > 			  r->name);
> > 	}
> > }
> 
> Agreed.  What's the schedule for pushing net-dev to Linus?  I'm
> currently at Korea Linux Forum, and I was originally planning on
> pushing random.git to Linus sometime today, but I'm also willing to
> wait for net-dev to go first.  Either way, we should make sure Linus
> is aware of the agreed-upon resolution of the merge conflict.

net-next is already on its way: http://markmail.org/message/ihccweynhtpdd66u

Greetings,

  Hannes
