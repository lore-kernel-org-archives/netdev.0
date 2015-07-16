From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -next 0/6] Per network namespace netfilter chains
Date: Thu, 16 Jul 2015 13:01:46 +0200
Message-ID: <20150716110146.GA3920@salvia>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
 <87r3pae5hn.fsf@x220.int.ebiederm.org>
 <878uansj4d.fsf_-_@x220.int.ebiederm.org>
 <20150715172038.GA4319@salvia>
 <87vbdljifn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87vbdljifn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 15, 2015 at 03:05:00PM -0500, Eric W. Biederman wrote:
> Pablo Neira Ayuso <pablo@netfilter.org> writes:
[...]
> >> There are lots of other possible and desirable cleanups but this one is
> >> a core change needed to make the other changes independent small
> >> changes.
> >
> > The state->net field will kill that dev_net(...) ? x : y; all over the
> > code, that would be nice.
> 
> Yes it will.  I intend to do that after this patchset settles so I am
> not dealing with more than one issue at a time.  Otherwise there
> is too much work at once.

Sure, thanks.

> > Some comments on your patchset:
> >
> > * 1/6 netfilter: nf_queue: Don't recompute the hook_list head
> >
> > I already passed this to current nf as you insisted on getting this,
> > and for the sake of correctness, so it's basically already in David's
> > net tree.
> 
> I would have expected this patch to be somewhere.  I did not see
> this change in net-next when I wrote the patchset (which seemed
> like a good approximation of the latest thing available).  If I
> overlooked and the patch has already made it to Dave then my apologies
> for being redundant.
> 
> I still don't see this patch in your pending branch.
> 
> Am I missing something?

It doesn't show yet in net-next, but it's already in net:

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=f307170d6e591a48529425b1ed6ca835790995a9

David periodically pulls net into net-next, so it will show there too
at some point.
