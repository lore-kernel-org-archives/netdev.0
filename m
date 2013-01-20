From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 13:47:01 -0500 (EST)
Message-ID: <391440283.93368.1358707621420.JavaMail.root@elliptictech.com>
References: <1358705471.2494.51.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358705471.2494.51.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "David Dillow" <dave@thedillows.org>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Sent: Sunday, 20 January, 2013 1:11:11 PM
> Subject: Re: IPsec AH use of ahash
> 
> On Sun, 2013-01-20 at 12:40 -0500, Tom St Denis wrote:
> > > On Sun, 2013-01-20 at 10:07 -0500, Tom St Denis wrote:
> > > > In all likelihood I will submit a revised CMAC patch but it'll
> > > > take
> > > > time before I can get business hours to work on it.  So instead
> > > > of
> > > > having a maintainer just touch it up we're all going to lose
> > > > out
> > > > because of pride?
> > > 
> > > Yes -- but it would seem to be yours that presents the problem.
> > 
> > Not really.  Again, *I* have this content.  You do not.
> 
> You mean the content at http://lkml.org/lkml/2012/12/11/369 ?
> 
> Funny how posting to an mailing list works...

I posted that in December ... it wasn't till January that I got the first reply back about it failing to meet the coding "standards."  Do you honestly expect people to sit on their hands for a month each time simple requests float by?

Furthermore, it's not merged into mainline.  So no, you don't have the content.  

> >  And the only reason you don't is because someone with pull-request
> > authority is too lazy [or apathetic] to make minor cosmetic changes
> > and get the change pushed through the process.
> 
> Someone like the author?

You mean the maintainer right?  If I have to do all of the work I should get all of the credit.
  
> > Furthermore I don't think you get how the business side of this
> > works.
> 
> I've been doing both kernel and proprietary development for close to
> two
> decades, so you might be surprised. I see it the other way around --
> you
> don't see how the open source part works, and are expecting to
> substitute your proprietary process -- where crap code that "works"
> is
> preferred, to hell with trying to maintain consistency,
> maintainability,
> or even readability.

Um ok that's uncalled for.  What part of the fact my CMAC code is like 90% verbatim copied from the XCBC code do you not understand?   If you think the CMAC patch was bad then you better call up the authors of the XCBC code and call them out for it too.  Stop being hypocritical.

You claimed my code fails to maintain "consistency" ... IT'S COPIED FROM EXISTING CODE.  Your complaint makes no sense not to mention it's insulting.

Furthermore, as someone who ran OSS projects (some of which are in millions of devices around the world) I understood to cherish user contributions.  Even if they needed polishing up.  I did the bitch work of documenting, testing, packaging, development, debugging, and support.  It's far far far too common to see OSS developers shy away from the less fun side of software development...

I called out the maintainers here because because not only do they not maintain the integrity of the code for which they claim authority but they are hostile towards outside contributions with ridiculous standards that they themselves don't even adhere to.  Code that they work on in the kernel doesn't meet ANY of the standards set forth that I was supposed to magically divine applied here..
 
> You sold your boss a bill of goods, then -- that may fly in your
> shop,
> but that doesn't work here. It is well known that there is likely to
> be
> several rounds of review, and this isn't a new thing.

Ok sure but why does that involve me re-writing the patch for cosmetic reasons?  I agreed that adding the () around the ^/& expressions would be a good idea.  However, how is it a good use of my time to re-write the patch (which includes lines of code I didn't write in the first place) for coding styles that are not actually used in the kernel?

I **COPIED** existing code.  Yet somehow my code isn't good enough?

> I do know this, and I also know that the kernel is much better
> documented than the most of the closed source code bases I've looked
> at
> in my career.

That's not really an excuse for lack of documentation/comments.  

> You think davem is lazy? Gruff, sure, but lazy? Well, thank you for
> illuminating your grasp of reality.

I was a one man shop running open source math/crypto libraries yet I wrote tons of well commented code, 100s of pages of documentation, ran user support, and did all the other things real developers do.  

If they can't add missing ()'s (which aren't strictly needed btw) on their own and merge the code into maintain then they're not much of developers now are they?

> There's a difference between patching an existing file, and
> introducing
> a new one. Should you have introduced a new file based on AH, I
> suspect
> it would also need some cleaning up.

Except when the motto is "use the source luke" you shouldn't be surprised when ... people use the source as a template for getting work done.  If you guys have such a damn problem with this you should maintain your code so it serves as an example to others.  Stop being a hypocrite.

> Anyways, I'll stop feeding the troll now. You've made it quite clear
> that no one is going to convince you, and calling the maintainers
> lazy
> and hypocrites isn't going to convince them.

I'm sure I'll re-write the patch [when I can't say].  I'm not in a position to sell the AH-AEAD work to my bosses because the ROI just won't be there.  For now we and our customers will have access to CMAC and nobody else will which is just a crying shame.

I'm not trying to pick a fight I'm trying to point out flaws in the system.  That you guys are so immobile on it is a shame.  I'd love to sell the idea to my bosses of cleaning up the CryptoAPI/IPsec maybe down the road merging our hardware drivers into mainline but it's not a case I can really make right now.  We make due quite fine with a private GPL tree of code but that's the opposite of how this should work.

Tom
