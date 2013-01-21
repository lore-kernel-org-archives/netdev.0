From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Mon, 21 Jan 2013 08:45:49 -0500 (EST)
Message-ID: <1924594099.94729.1358775949651.JavaMail.root@elliptictech.com>
References: <1358775534.21576.8.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>, Borislav Petkov <bp@alien8.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358775534.21576.8.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Steven Rostedt" <rostedt@goodmis.org>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "David Dillow" <dave@thedillows.org>, "Borislav Petkov" <bp@alien8.de>, linux-kernel@vger.kernel.org,
> netdev@vger.kernel.org
> Sent: Monday, 21 January, 2013 8:38:54 AM
> Subject: Re: IPsec AH use of ahash

> > The missing semi-colon is in fact missing and for that I apologize.
> >  This btw is the first legitimate gripe with the code thus far.
> 
> I've also found that those that have poor coding styles also have
> more
> of these "legitimate" problems too. Which is another reason not to
> accept patches with coding style issues.

I find that 73% of all stats are made up.

What actually happened was testmgr.h was being #ifdef'ed out so despite the fact I saw "testmgr.o" on the build process it wasn't actually doing anything.  Not blaming anyone here .. just missed a build option.

I wouldn't have submitted it if the code failed to compile.

> > Though I must say this code has "compiled" in 3.6, 3.6.7, 3.7, and
> > 3.8 without error so it's not surprising it wasn't caught.  After
> > having consulted the "documentation" I never really did figure out
> > how to get testmgr to run so I took a bit of leap of faith there
> > that everything was fine.  Not really an excuse but it is at least
> > an observable hole in the build documentation.
> 
> Did you try different configs? Before submitting my code, I run under
> 8
> different configs. SMP, non-SMP, PREEMPT, non PREEMPT, etc. also I
> run a
> few random configs before submitting.

None of course apply to this code [or shouldn't at least].  

> Until you can play by the rules, don't bother playing. Feel free to
> dump
> code on LKML. Maybe someone that knows how to play the game will take
> it. But leave your gripes to your managers. No one here, but you,
> thinks
> there's a problem with the frame work.

I actually did resubmit this morning with most of the checkpatch issues fixed. 

I'll avoid beating the dead horse though I'd like to move forward.

> > At least the testmgr errors are something I can work on whenever
> > without setting up a lab so likely that'll be something I can
> > tackle today actually.
> 
> While you're at it. You could spend an extra 5 minutes cleaning up
> the
> coding style ;-)

It actually took me about 45 minutes and about 5 revisions of the patches to clean up all the random coding style gripes from checkpatch.  The only reason I worked on it though is that there were build errors.  That way I can justify it to my boss.

Seriously, no spaces on the trailing edge of multi line comments?  :-/

Anyways, I did re-submit.  I still have no idea how testmgr works but hopefully someone can pick it up from there.

Tom
