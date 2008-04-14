From: Willy Tarreau <w@1wt.eu>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 12:00:18 +0200
Message-ID: <20080414100018.GA10378@1wt.eu>
References: <47FEADCB.7070104@rtr.ca> <22880.1207943922@turing-police.cc.vt.edu> <47FFE5DA.8000709@imap.cc> <200804132040.12138.rjw@sisk.pl> <20080413184730.GD8474@1wt.eu> <874pa4wyfj.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753361AbYDNKIR@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <874pa4wyfj.fsf@basil.nowhere.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2008 at 11:58:08AM +0200, Andi Kleen wrote:
> Willy Tarreau <w@1wt.eu> writes:
> 
> > Linux is the *only* product which requires
> > the bug reporter to find the fault change (yes, I know, it's scalable).
> 
> It's a pretty common procedure for compilers (gcc, llvm) too, although
> they have the advantage that given a test case usually someone else
> can run the bisect procedure because they do not depend on the underlying
> hardware 
> 
> That's unfortunately not the case for most kernel bugs, although
> sometimes it is possible given a hardware independent test case. And
> while most of the kernel code is drivers and arch, a lot of it is
> still pretty hardware independent, so at least in some cases it is
> possible to submit test cases and then let someone else (like a bug
> master) do the bisect.
> 
> Of course it is unclear if producing a submittable test case will be
> actually any faster than just running bisect for the user.
> 
> That said I agree it's a big burden to run bisect for everything
> because it can take very long (especially if the problem
> is not trivially reproducable) 
> 
> It would be fair at least if maintainers always gave some candidate
> commit ids when asking for bisect for likely changes that could
> have matched the bug.  Then those could be checked quickly first
> before doing the full run.
> 
> While that will not always work it would be still a useful short cut
> and save a lot of time for the reporter.

And most of all, the reporter would not feel like the bisection is
the default response !

> -Andi

Willy
