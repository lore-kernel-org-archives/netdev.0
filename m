From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Fri, 18 Jan 2013 17:31:45 -0500 (EST)
Message-ID: <1702471741.91455.1358548305936.JavaMail.root@elliptictech.com>
References: <20130118221614.GA5616@ppwaskie-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130118221614.GA5616@ppwaskie-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "David Miller" <davem@davemloft.net>, "steffen klassert" <steffen.klassert@secunet.com>,
> herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Sent: Friday, 18 January, 2013 5:16:14 PM
> Subject: Re: IPsec AH use of ahash
> 
> On Fri, Jan 18, 2013 at 03:53:44PM -0500, Tom St Denis wrote:
> > Admittedly I'm new to the kernel scene but what exactly is a
> > "maintainer" then?
> 
> Maintainers are ultimately responsible for content that flows into a
> tree
> or subsystem.  That means they must command a level of expertise on
> everything about the code they maintain to decide what goes in and
> what
> doesn't.  This doesn't mean they know everything about everything,
> but
> their judgement is built on experience and time in the job.
> 
> > Suppose I invest time to re-write the IPv4/v6 AH code to correctly
> > use AEAD instead of ahash, to then perform the testing required,
> > etc... do I get credit as a maintainer in the IPsec tree?
> 
> Working on a single thing doesn't make you a maintainer, it makes you
> a
> contributor.  There are vastly more contributors than maintainers,
> and that's
> how it should be.  A maintainer depends on contributors to be the
> people
> in the trenches dealing with the specifics of things like the AH
> code, in
> this case.  However, a maintainer's signed-off-by on a contributor's
> code
> also makes the maintainer accountable for the code being included in
> the
> kernel.  This is not something to be taken lightly.

My gripe here is suppose I spend professional paid time working on an AH patch to [in my opinion] fix it and then I get ignored/stonewalled/etc because I didn't cross a t or dot an i ... what is my incentive to contribute publicly?  I can't go to my boss and get time to work on it if the likelihood of seeing it in mainline is basically around 0%.

The CMAC patch for instance was a dead simple patch that even modulo the missing () around an xor expression should have been a no-brainer to merge into their trees for the eventual 3.8 release cycle.  Instead I get nitpicked and frankly publicly bashed on coding quality despite the fact it's entirely based on existing UNMAINTAINED [apparently] kernel code.
 
> I would recommend just hanging out on the netdev list and read it for
> a few
> days.  There are a *large* number of patches that are critiqued and
> asked
> to either be rewritten, modified, or dropped.  The whole point of the
> community is to share your work and code, and then either defend the
> code,
> or incorporate feedback and resubmit.  Many patches take multiple
> spins before
> they're applied.  It's the nature of the community.

It's the nature of a hostile working environment.  Making me re-submit in the hopes of a) getting acknowledged and b) accepted is humiliating and frankly a waste of time.  

It would have taken them very little time to merge the patch I sent in, fix the (), maybe address some of the coding style "errors" and then form a patch for mainline based on that.  Don't you think I have better things to do than re-submit working code repeatedly?

> Note that quite a bit of code has been in the kernel for a long time.
>  There
> will be examples of code that doesn't conform; there are millions of
> lines of
> code in Linux, nothing is going to be perfect.  If you find your code
> doesn't
> meet a coding standard, then respin the patch, and then use that
> opportunity
> to fix the other code you've seen to meet the coding standard.
>  That's two
> contributions that only improve the kernel, and increases your
> credibility
> as an active contributor.

Ok but as "maintainers" they should be "maintaining" code ... if coding standards change (and btw the XCBC code was likely submitted long after the coding standards were put in place) then the maintainers should go through code they're responsible for and update it.

"xcbc.c" for instance was last touched in 2011.  It hasn't been maintained at all apparently.  There were a handful of patches against it ... none which address these "coding standards."
 
Tom
