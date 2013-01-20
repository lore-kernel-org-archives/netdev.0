From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 12:40:20 -0500 (EST)
Message-ID: <1361595885.93211.1358703620681.JavaMail.root@elliptictech.com>
References: <1358699692.2494.29.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358699692.2494.29.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "David Dillow" <dave@thedillows.org>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Sent: Sunday, 20 January, 2013 11:34:52 AM
> Subject: Re: IPsec AH use of ahash
> 
> On Sun, 2013-01-20 at 10:07 -0500, Tom St Denis wrote:
> > In all likelihood I will submit a revised CMAC patch but it'll take
> > time before I can get business hours to work on it.  So instead of
> > having a maintainer just touch it up we're all going to lose out
> > because of pride?
> 
> Yes -- but it would seem to be yours that presents the problem.

Not really.  Again, *I* have this content.  You do not.  And the only reason you don't is because someone with pull-request authority is too lazy [or apathetic] to make minor cosmetic changes and get the change pushed through the process.
 
> I'm sure you could have fixed your patch up in the amount of time
> you've
> spent railing against the push-back. How much of that were you
> billing
> for, and is that a productive use your employer's money? Even on your
> own time, how productive has that been? Do you feel better, having
> vented?

I was hoping to have a constructive conversation in which the maintainers could come clean about the complete hypocrisy of claiming that the source is the reference [since there is no documentation for anything in the kernel] and then saying you can't actually read the source when you want to contribute. Then to tell me I have to adhere to some coding standard (which all things aside I don't agree with in the first place) despite the fact that *none* of the code in the kernel complies with it.

Furthermore I don't think you get how the business side of this works.

I was tasked with getting CMAC to work with IPsec.  I did.  I sent the patch off to the LKML.  My boss tasked me with other work (totally unrelated to IPsec) since in their eyes the project was done [we do after all have CMAC support].  

To then go back to my boss and say I need another couple of hours to "clean" it, re-test it in our IPsec lab and then resubmit it in hopes that the "maintainers" don't find some other reason to reject it is totally unprofessional and unproductive.

> You don't think the maintainers are maintaining if they don't clean
> up
> after every random contributor -- fine, call them lieutenants then.
> Their job is to guide the new development towards the goals for the
> system, review patches, and develop new features.

Know this.  Being a software developer involves doing a lot of lowly work that most people aren't excited by.  You guys already don't comment/document your code.  It's unreasonable to assume you can't at least maintain your own style guidelines... I mean what does a maintainer do?

> You'll notice I didn't say "reformat code when standards change."
> This
> is a distributed project and it doesn't scale to have the code
> continually in flux -- reformatting creates conflicts in other
> contributors patches, which then consume all of a lieutenant's time
> if
> they were to try to fix up each one for them. It's much better to
> push
> push that work out to the edge of the network -- put another way,
> "many
> hands make light work." Fixing existing formatting problems is
> acceptable in a patch series if one is working in the area, but it is
> rare that a series devoted solely to that kind of cleanup gets in.

Because the volunteers don't want to do lowly bitch work.

I'm not a volunteer.  I was paid to write the CMAC patch since our project supports it [amongst other modes including AH-GMAC...].   But that said we don't work on kernel time.  I don't bend my schedule around the whims of some moderator who is too damn lazy to do a bit of lowly work that they think is beneath them.
 
> The coding styles have evolved over time, and are different for
> different areas of the kernel -- for example, most of the kernel
> wants
> '/*' on its own line for a multi-line comment, but under net/ it
> should
> not. You should try to match the style in your area -- claiming that
> the
> cryto/ code does it one way is unlikely to sway opinion in net/.
> Different lieutenants, different opinions.

Which of course is asinine.
 
> As for the existing style issues in net/ipv4/ah4.c you posted, no,
> your
> patch adding a feature in ah4 would probably not been rejected
> because
> of the existing issues, though if one was in the middle of your
> changes,
> it is possible that your would be asked to fix it. As for the issues
> checkpatch.pl found, they are in many cases legitimate, but are also
> the
> exceptions -- there are plenty of counter-examples in that file
> showing
> the preferred style.

Except that my CMAC content came almost exclusively from XCBC which was already in the kernel.  Since you guys did reject the patch on the grounds of coding style why would I assume my AH patches would be any different?

Tom
