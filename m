From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 18:50:54 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708181828300.29105@enigma.security.iitk.ac.in>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <c298f0e3f9e49c9dd2d326115d156084@kernel.crashing.org>
 <alpine.LFD.0.999.0708180002290.3666@enigma.security.iitk.ac.in>
 <a51ab88dc00f8d7fd44f79400671d259@kernel.crashing.org>
 <alpine.LFD.0.999.0708180522120.3666@enigma.security.iitk.ac.in>
 <c0115c88da5d6756502e0c0499faa71f@kernel.crashing.org> <alpine.LFD.0.999.0708!
 180556330.3666@enigma.security.iitk.ac.in> <67eca5ac43d3b1dbd1a04c7c36aebd5a@kernel.crashing.org>
 <alpine.LFD.0.999.0708180833520.3666@enigma! .security.iitk.ac.in>
 <6db2717888e35173c9f36ef0b8c7b32b@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?iso-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	ak@suse.de, cfriesen@nortel.com, rpjday@mindspring.com,
	Netdev <netdev@vger.kernel.org>, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org,
	Andrew Morton <akpm@linux-foundation.org>,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46641 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766AbXHRNIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2007 09:08:36 -0400
In-Reply-To: <6db2717888e35173c9f36ef0b8c7b32b@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ LOL, you _are_ shockingly petty! ]


On Sat, 18 Aug 2007, Segher Boessenkool wrote:

> > > The documentation simply doesn't say "+m" is allowed.  The code to
> > > allow it was added for the benefit of people who do not read the
> > > documentation.  Documentation for "+m" might get added later if it
> > > is decided this [the code, not the documentation] is a sane thing
> > > to have (which isn't directly obvious).
> > 
> > Huh?
> > 
> > "If the (current) documentation doesn't match up with the (current)
> > code, then _at least one_ of them has to be (as of current) wrong."
> > 
> > I wonder how could you even try to disagree with that.
> 
> Easy.
> 
> The GCC documentation you're referring to is the user's manual.
> See the blurb on the first page:
> 
> "This manual documents how to use the GNU compilers, as well as their
> features and incompatibilities, and how to report bugs.  It corresponds
> to GCC version 4.3.0.  The internals of the GNU compilers, including
> how to port them to new targets and some information about how to write
> front ends for new languages, are documented in a separate manual."
> 
> _How to use_.  This documentation doesn't describe in minute detail
> everything the compiler does (see the source code for that -- no, it
> isn't described in the internals manual either).

Wow, now that's a nice "disclaimer". By your (poor) standards of writing
documentation, one can as well write any factually incorrect stuff that
one wants in a document once you've got such a blurb in place :-)


> If it doesn't tell you how to use "+m", and even tells you _not_ to
> use it, maybe that is what it means to say?  It doesn't mean "+m"
> doesn't actually do something.  It also doesn't mean it does what
> you think it should do.  It might do just that of course.  But treating
> writing C code as an empirical science isn't such a smart idea.

Oh, really? Considering how much is (left out of being) documented, often
one would reasonably have to experimentally see (with testcases) how the
compiler behaves for some given code. Well, at least _I_ do it often
(several others on this list do as well), and I think there's everything
smart about it rather than having to read gcc sources -- I'd be surprised
(unless you have infinite free time on your hands, which does look like
teh case actually) if someone actually prefers reading gcc sources first
to know what/how gcc does something for some given code, rather than
simply write it out, compile and look the generated code (saves time for
those who don't have an infinite amount of it).


> > And I didn't go whining about this ... you asked me. (I think I'd said
> > something to the effect of GCC docs are often wrong,
> 
> No need to guess at what you said, even if you managed to delete
> your own mail already, there are plenty of free web-based archives
> around.  You said:
> 
> > See, "volatile" C keyword, for all it's ill-definition and dodgy
> > semantics, is still at least given somewhat of a treatment in the C
> > standard (whose quality is ... ummm, sadly not always good and clear,
> > but unsurprisingly, still about 5,482 orders-of-magnitude times
> > better than GCC docs).

Try _reading_ what I said there, for a change, dude. I'd originally only
said "unless GCC's docs is yet again wrong" ... then _you_ asked me what,
after which this discussion began and I wrote the above [which I fully
agree with -- so what if I used hyperbole in my sentence (yup, that was
intended, and obviously, exaggeration), am I not even allowed to do that?
Man, you're a Nazi or what ...] I didn't go whining about on my own as
you'd had earlier suggested, until _you_ asked me.

[ Ick, I somehow managed to reply this ... this is such a ...
  *disgustingly* petty argument you made here. ]


> > which is true,
> 
> Yes, documentation of that size often has shortcomings.  No surprise
> there.  However, great effort is made to make it better documentation,
> and especially to keep it up to date; if you find any errors or
> omissions, please report them.  There are many ways how to do that,
> see the GCC homepage.</end-of-marketing-blurb>
                         ^^^^^^^^^^^^^^^^^^^^^^

Looks like you even get paid :-)


> > but probably you feel saying that is "not allowed" on non-gcc lists?)
> 
> [amazingly pointless stuff snipped]
> 
> > As for the "PR"
> > you're requesting me to file with GCC for this, that
> > gcc-patches@ thread did precisely that
> 
> [more amazingly pointless stuff snipped]
> 
> > and more (submitted a patch to
> > said documentation -- and no, saying "documentation might get added
> > later" is totally bogus and nonsensical -- documentation exists to
> > document current behaviour, not past).
> 
> When code like you want to write becomes a supported feature, that
> will be reflected in the user manual.  It is completely nonsensical
> to expect everything that is *not* a supported feature to be mentioned
> there.

What crap. It is _perfectly reasonable_ to expect (current) documentation
to keep up with (current) code behaviour. In fact trying to justify such
a state is completely bogus and nonsensical.


Satyam
