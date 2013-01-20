From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 17:54:07 -0500
Message-ID: <20130120225407.GB5434@home.goodmis.org>
References: <1358705471.2494.51.camel@obelisk.thedillows.org>
 <391440283.93368.1358707621420.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <391440283.93368.1358707621420.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 20, 2013 at 01:47:01PM -0500, Tom St Denis wrote:
> 
> 
> > 
> > You mean the content at http://lkml.org/lkml/2012/12/11/369 ?
> > 
> > Funny how posting to an mailing list works...
> 
> I posted that in December ... it wasn't till January that I got the first reply back about it failing to meet the coding "standards."  Do you honestly expect people to sit on their hands for a month each time simple requests float by?

You posted in mid December. Guess what, that's a high time for people to
take off for vacations. Also it's a time where a lot of year end work
needs to get done and yes, new code does get pushed to the bottom of the
priority list.

A polite "ping" is allowed if you don't hear back within a week. But
still, this time of year is not the best for new work to be added.

BTW, how much is your company paying David Miller to fix your
submissions?  If you're not paying him, don't expect things to get done
at your convenience, or at all.

> 
> Furthermore, it's not merged into mainline.  So no, you don't have the content.  

Seems nobody (besides you) cares at the moment. When someone comes by
and wants this feature, as you so nicely posted it to LKML, it's out
there. They can then clean it up to David's liking, and it will be
added. There is no harm on our side.

You on the other hand need to constantly send patches to your customers.
Seems that the one being hurt by not including these patches is still
you.

> 
> > >  And the only reason you don't is because someone with pull-request
> > > authority is too lazy [or apathetic] to make minor cosmetic changes
> > > and get the change pushed through the process.
> > 
> > Someone like the author?
> 
> You mean the maintainer right?  If I have to do all of the work I should get all of the credit.

You do get credit for the code that you submit. I have people send me
code for a new feature, and I expect them to still maintain it. They
usually have their name at the top of the file as the author.

But the maintainer of the subsystem has the right to control how things
get added to their system, as they are the ones ultimately responsible
for the code out there. If there's a bug, the maintainer is the one that
gets the notice. That's what they maintain, not cleaning up code from
people that want new features. A maintainer is the one that has to make
sure that the code continues to work.

>   
> > > Furthermore I don't think you get how the business side of this
> > > works.
> > 
> > I've been doing both kernel and proprietary development for close to
> > two
> > decades, so you might be surprised. I see it the other way around --
> > you
> > don't see how the open source part works, and are expecting to
> > substitute your proprietary process -- where crap code that "works"
> > is
> > preferred, to hell with trying to maintain consistency,
> > maintainability,
> > or even readability.
> 
> Um ok that's uncalled for.  What part of the fact my CMAC code is like 90% verbatim copied from the XCBC code do you not understand?

So what?

That code is there. There's a lot of code in the kernel that needs to be
cleaned up. I've done exactly as you did. I copied code, submitted it to
the maintainer, and it was rejected because things have changed since the
time of the code I copied. Did I bitch to the maintainer saying "hey, I
copied this and you should accept it because you have that there." No, I
did not. Actually what I did was fix my patch to what was the right way
to do things, and then I FIXED THE CODE I COPIED!!!


>If you think the CMAC patch was bad then you better call up the authors of the XCBC code and call them out for it too.  Stop being hypocritical.

Oh shut up!

The XCBC code is in there today. And yes, if you submitted patches to
clean that code up, I'm sure those will be accepted. But changing code
in the kernel does take work, including removing said code. But that's
still no reason to allow more code that will need to be cleaned up in
the future. Fix it before it gets in.


> 
> You claimed my code fails to maintain "consistency" ... IT'S COPIED FROM EXISTING CODE.  Your complaint makes no sense not to mention it's insulting.

He's not the one calling people lazy. Frankly sir, you're the one being
offensive and a hypocrite.

> 
> Furthermore, as someone who ran OSS projects (some of which are in millions of devices around the world) I understood to cherish user contributions.  Even if they needed polishing up.  I did the bitch work of documenting, testing, packaging, development, debugging, and support.  It's far far far too common to see OSS developers shy away from the less fun side of software development...

I maintain OSS projects too. And because there's very few people that
contribute, I cherish submissions as well, and will do a lot of the
grunt work that really should be done by the contributor. But the Linux
kernel is much bigger. It changes something like 3000 lines of code a day!

Maintainers do not scale well with such a project, and yes, it's up to
the contributors to take up the slack.


> 
> I called out the maintainers here because because not only do they not maintain the integrity of the code for which they claim authority but they are hostile towards outside contributions with ridiculous standards that they themselves don't even adhere to.  Code that they work on in the kernel doesn't meet ANY of the standards set forth that I was supposed to magically divine applied here..

My God, you sound like a 2 year old.

Suck it up, and do the fixes. It's not the time you are worried about,
as you most definitely spent more time bitching to everyone than it
would have taken you to clean up your work.

>  
> > You sold your boss a bill of goods, then -- that may fly in your
> > shop,
> > but that doesn't work here. It is well known that there is likely to
> > be
> > several rounds of review, and this isn't a new thing.
> 
> Ok sure but why does that involve me re-writing the patch for cosmetic reasons?

Because you are the one that cares about it being submitted. If someone
else cares, they'll take your code and fix it, to get it in.

>I agreed that adding the () around the ^/& expressions would be a good idea.  However, how is it a good use of my time to re-write the patch (which includes lines of code I didn't write in the first place) for coding styles that are not actually used in the kernel?

It's better on your time than the maintainers. Do not try to compare
your little OSS project to the Linux Kernel. They are two different
beasts.

> 
> I **COPIED** existing code.  Yet somehow my code isn't good enough?

And that's the perfect time to clean it up.

> 
> > I do know this, and I also know that the kernel is much better
> > documented than the most of the closed source code bases I've looked
> > at
> > in my career.
> 
> That's not really an excuse for lack of documentation/comments.  

We can always use more documentation and comments. And actually, the
kernel has been getting better at this regard. New code usually does get
better comments than what is currently in the kernel from years past.

> 
> > You think davem is lazy? Gruff, sure, but lazy? Well, thank you for
> > illuminating your grasp of reality.
> 
> I was a one man shop running open source math/crypto libraries yet I wrote tons of well commented code, 100s of pages of documentation, ran user support, and did all the other things real developers do.  
> 
> If they can't add missing ()'s (which aren't strictly needed btw) on their own and merge the code into maintain then they're not much of developers now are they?

Because honestly I doubt Dave cares about it. Again, how much are you
paying him?  You're the one that wants this feature. If someone else
wants it, they'll do this without the 2 year old bitch rant.

> 
> > There's a difference between patching an existing file, and
> > introducing
> > a new one. Should you have introduced a new file based on AH, I
> > suspect
> > it would also need some cleaning up.
> 
> Except when the motto is "use the source luke" you shouldn't be surprised when ... people use the source as a template for getting work done.  If you guys have such a damn problem with this you should maintain your code so it serves as an example to others.  Stop being a hypocrite.

Fix the source Luke! It's not a big deal.

> 
> > Anyways, I'll stop feeding the troll now. You've made it quite clear
> > that no one is going to convince you, and calling the maintainers
> > lazy
> > and hypocrites isn't going to convince them.
> 
> I'm sure I'll re-write the patch [when I can't say].  I'm not in a position to sell the AH-AEAD work to my bosses because the ROI just won't be there.  For now we and our customers will have access to CMAC and nobody else will which is just a crying shame.

And when someone wants it, they will either fix up what you did, or pay
someone to do it for them.

> 
> I'm not trying to pick a fight I'm trying to point out flaws in the system.  That you guys are so immobile on it is a shame.  I'd love to sell the idea to my bosses of cleaning up the CryptoAPI/IPsec maybe down the road merging our hardware drivers into mainline but it's not a case I can really make right now.  We make due quite fine with a private GPL tree of code but that's the opposite of how this should work.

You did a good job at picking a fight here. I don't see a flaw in the
system. I see a way to get new code in at a higher standard than the old
code, and over time fix the old code so that it catches up with what's
there today. This is what kernel janitors was created for.

-- Steve
