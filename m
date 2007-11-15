From: Neil Brown <neilb@suse.de>
Subject: Re: [BUG] New Kernel Bugs
Date: Thu, 15 Nov 2007 14:06:58 +1100
Message-ID: <18235.47058.757009.665849__37617.5369056456$1195096073$gmane$org@notabene.brown>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	<20071113134029.GA30978@elte.hu>
	<4739AFE0.20705@rtr.ca>
	<200711131734.11353.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <liml@rtr.ca>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758443AbXKODH1@vger.kernel.org>
In-Reply-To: message from Denys Vlasenko on Tuesday November 13
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday November 13, vda.linux@googlemail.com wrote:
> On Tuesday 13 November 2007 07:08, Mark Lord wrote:
> > Ingo Molnar wrote:
> > ..
> >
> > > This is all QA-101 that _cannot be argued against on a rational basis_,
> > > it's just that these sorts of things have been largely ignored for
> > > years, in favor of the all-too-easy "open source means many eyeballs and
> > > that is our QA" answer, which is a _good_ answer but by far not the most
> > > intelligent answer! Today "many eyeballs" is simply not good enough and
> > > nature (and other OS projects) will route us around if we dont change.
> >
> > ..
> >
> > QA-101 and "many eyeballs" are not at all in opposition.
> > The latter is how we find out about bugs on uncommon hardware,
> > and the former is what we need to track them and overall quality.
> >
> > A HUGE problem I have with current "efforts", is that once someone
> > reports a bug, the onus seems to be 99% on the *reporter* to find
> > the exact line of code or commit.  Ghad what a repressive method.
> 
> This is the only method that scales.

That sounds overly hash, and the rest of you mail sounds much more
moderate and sensible - I can only assume you were using hyperbole??

Putting the "onus on the reporter" is simply not going to work unless
you have a business relationship.  In the community, we are all
volunteering our time (well, maybe my employer is volunteering my time
to do community support, but the effect is the same).

I would hope that the focus of developers is to empower bug reporters
to provide further information (and as has been said, "git bisect" is
a great empowerer).  Some people will be incredibly help, especially
if you ask politely and say thankyou.  Others won't for any of a
number of reasons - and maybe that means their bug won't get fixed.

To my eyes, the "only method that scales" is investing effort in
encouraging and training bug reporters.  Some of that effort might not
produce results, but when others among those you have encouraged start
answering the newbee questions on the list and save you the time, you
get a distinct feeling that it was all worth while.


I think we are in agreement - I just wanted to take issue with that
one sentence :-)  The rest is great.

NeilBrown

> 
> Developer has only 24 hours in each day, and sometimes he needs to eat,
> sleep, and maybe even pay attention to e.g. his kids.
> 
> But bug reporters are much more numerous and they have more
> hours in one day combined.
> 
> BUT - it means that developers should try to increase user base,
> not scare users away.
> 
> > And if the "developer" who broke the damn thing, or who at least
> > "claims" to be supporting that code, cannot "reproduce" the bug,
> > they drop it completely.
> 
> Developer should let reporter know that reporter needs to help
> a bit here. Sometimes a bit of hand holding is needed, but it
> pays off because you breed more qualified testers/bug reporters.
> 
> > Contrast that flawed approach with how Linus does things..
> > he thinks through the symptoms, matches them to the code,
> > and figures out what the few possibilities might be,
> > and feeds back some trial balloon patches for the bug reporter to try.
> >
> > MUCH better.
> >
> > And remember, *I'm* an old-time Linux kernel developer.. just think about
> > the people reporting bugs who haven't been around here since 1992..
> 
> Yes. Developers should not grow more and more unhelpful
> and arrogant towards their users just because inexperienced
> users send incomplete/poorly written bug reports.
> They need to provide help, not humiliate/ignore.
> 
> I think we agree here.
> --
> vda
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
