From: David Dillow <dave@thedillows.org>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 13:11:11 -0500
Message-ID: <1358705471.2494.51.camel@obelisk.thedillows.org>
References: <1361595885.93211.1358703620681.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361595885.93211.1358703620681.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-01-20 at 12:40 -0500, Tom St Denis wrote:
> > On Sun, 2013-01-20 at 10:07 -0500, Tom St Denis wrote:
> > > In all likelihood I will submit a revised CMAC patch but it'll take
> > > time before I can get business hours to work on it.  So instead of
> > > having a maintainer just touch it up we're all going to lose out
> > > because of pride?
> > 
> > Yes -- but it would seem to be yours that presents the problem.
> 
> Not really.  Again, *I* have this content.  You do not. 

You mean the content at http://lkml.org/lkml/2012/12/11/369 ?

Funny how posting to an mailing list works...

>  And the only reason you don't is because someone with pull-request
> authority is too lazy [or apathetic] to make minor cosmetic changes
> and get the change pushed through the process.

Someone like the author?

> I was hoping to have a constructive conversation in which the
> maintainers could come clean about the complete hypocrisy of claiming
> that the source is the reference [since there is no documentation for
> anything in the kernel] and then saying you can't actually read the
> source when you want to contribute.

A conversation where you have already decided the outcome -- that's a
speech, not a dialogue.

> Furthermore I don't think you get how the business side of this works.

I've been doing both kernel and proprietary development for close to two
decades, so you might be surprised. I see it the other way around -- you
don't see how the open source part works, and are expecting to
substitute your proprietary process -- where crap code that "works" is
preferred, to hell with trying to maintain consistency, maintainability,
or even readability.

I've worked on those code bases, and the kernel is a breath of fresh air
in comparison.

> I was tasked with getting CMAC to work with IPsec.  I did.  I sent the
> patch off to the LKML.  My boss tasked me with other work (totally
> unrelated to IPsec) since in their eyes the project was done [we do
> after all have CMAC support].
> 
> To then go back to my boss and say I need another couple of hours to
> "clean" it, re-test it in our IPsec lab and then resubmit it in hopes
> that the "maintainers" don't find some other reason to reject it is
> totally unprofessional and unproductive.

You sold your boss a bill of goods, then -- that may fly in your shop,
but that doesn't work here. It is well known that there is likely to be
several rounds of review, and this isn't a new thing.

> > You don't think the maintainers are maintaining if they don't clean
> > up
> > after every random contributor -- fine, call them lieutenants then.
> > Their job is to guide the new development towards the goals for the
> > system, review patches, and develop new features.
> 
> Know this.  Being a software developer involves doing a lot of lowly
> work that most people aren't excited by.  You guys already don't
> comment/document your code.

I do know this, and I also know that the kernel is much better
documented than the most of the closed source code bases I've looked at
in my career.

> I'm not a volunteer.  I was paid to write the CMAC patch since our
> project supports it [amongst other modes including AH-GMAC...].   But
> that said we don't work on kernel time.  I don't bend my schedule
> around the whims of some moderator who is too damn lazy to do a bit of
> lowly work that they think is beneath them.

You think davem is lazy? Gruff, sure, but lazy? Well, thank you for
illuminating your grasp of reality.

> > As for the existing style issues in net/ipv4/ah4.c you posted, no,
> > your patch adding a feature in ah4 would probably not been rejected
> > because of the existing issues, though if one was in the middle of your
> > changes, it is possible that your would be asked to fix it.

> Except that my CMAC content came almost exclusively from XCBC which
> was already in the kernel.  Since you guys did reject the patch on the
> grounds of coding style why would I assume my AH patches would be any
> different?

There's a difference between patching an existing file, and introducing
a new one. Should you have introduced a new file based on AH, I suspect
it would also need some cleaning up.

Anyways, I'll stop feeding the troll now. You've made it quite clear
that no one is going to convince you, and calling the maintainers lazy
and hypocrites isn't going to convince them.
