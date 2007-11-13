From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 14:40:29 +0100
Message-ID: <20071113134029.GA30978@elte.hu>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <20071113041259.79c9a8c5.akpm@linux-foundation.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > > Do you believe that our response to bug reports is adequate?
> > 
> > Do you feel that making us feel and look like shit helps?
> 
> That doesn't answer my question.
> 
> See, first we need to work out whether we have a problem.  If we do 
> this, then we can then have a think about what to do about it.
> 
> I tried to convince the 2006 KS attendees that we have a problem and I 
> resoundingly failed.  People seemed to think that we're doing OK.
> 
> But it appears that data such as this contradicts that belief.
> 
> This is not a minor matter.  If the kernel _is_ slowly deteriorating 
> then this won't become readily apparent until it has been happening 
> for a number of years.  By that stage there will be so much work to do 
> to get us back to an acceptable level that it will take a huge effort.  
> And it will take a long time after that for the kerel to get its 
> reputation back.
> 
> So it is important that we catch deterioration *early* if it is 
> happening.

yes, yes, yes, and i agree with you that there is a problem. I tried to 
make this point at the 2007 KS: not only is degradation in quality not 
apparent for years, slow degradation in quality can give kernel 
developers the exact _opposite_ perception! (Fewer testers means fewer 
bugreports and that results in apparent "improved" quality and fewer 
reported regressions - while exactly the opposite is happening and 
testers are leaving us without giving us any indication that this is 
happening. We just dont notice.)

I'm not moaning about bugs that slip through - those are unavoidable 
facts of a high flux codebase. I'm moaning about reoccuring, avoidable 
bugs, i'm moaning about hostility towards testers, i'm moaning about 
hostility towards automated testing, i'm moaning about unnecessary hoops 
a willing (but unskilled) tester has to go through to help us out.

I tried to make the point that the only good approach is to remove our 
current subjective bias from quality metrics and to at least realize 
what a cavalier attitude we still have to QA. The moment we are able to 
_measure_ how bad we are, kernel developers will adopt in a second and 
will improve those metrics. Lets use more debug tools, both static and 
dynamic ones. Lets measure tester base and we need to measure _lost_ 
early adopters and the reasons why they are lost. Regression metrics are 
a very important first step too and i'm very happy about the increasing 
effort that is being spent on this.

This is all QA-101 that _cannot be argued against on a rational basis_, 
it's just that these sorts of things have been largely ignored for 
years, in favor of the all-too-easy "open source means many eyeballs and 
that is our QA" answer, which is a _good_ answer but by far not the most 
intelligent answer! Today "many eyeballs" is simply not good enough and 
nature (and other OS projects) will route us around if we dont change.

We kernel developers have been spoiled by years of abundance in testing 
resources. We squander tons of resources in this area, and we could be 
so much more economic about this without hindering our development model 
in any way. We could be so much better about QA and everyone would 
benefit without having to compromize on the incoming flux of changes - 
it's so much easier to write new features for a high quality kernel.

My current guesstimation is that we are utilizing our current testing 
resources at around 10% efficiency. (i.e. if we did an 'ideal' job we 
could fix 10 times as many bugs with the same size of tester effort!) It 
used to be around 5%. (and i mainly attribute the increase from 5% to 
10% to Andrew and the many other people who do kernel QA - kudos!) 10% 
is still awful and we very much suck.

Paradoxically, the "end product" is still considerably good quality in 
absolute terms because other pieces of our infrastructure are so good 
and powerful, but QA is still a 'weak link' of our path to the user that 
reduces the quality of the end result. We could _really_ be so much 
better without any compromises that hurt.

(and this is in no way directed at the networking folks - it holds for 
all of us. I have one main complaint about networking: the separate 
netdev list is a bad idea - networking regressions should be discussed 
and fixed on lkml, like most other subsystems are. Any artificial split 
of the lk discussion space is bad.)

	Ingo
