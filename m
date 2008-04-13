From: Willy Tarreau <w@1wt.eu>
Subject: Re: Reporting bugs and bisection (was: Re: 2.6.25-rc8: FTP transfer errors)
Date: Sun, 13 Apr 2008 20:47:30 +0200
Message-ID: <20080413184730.GD8474@1wt.eu>
References: <47FEADCB.7070104@rtr.ca> <22880.1207943922@turing-police.cc.vt.edu> <47FFE5DA.8000709@imap.cc> <200804132040.12138.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2943 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282AbYDMSyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 14:54:36 -0400
Content-Disposition: inline
In-Reply-To: <200804132040.12138.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2008 at 08:40:11PM +0200, Rafael J. Wysocki wrote:
> On Saturday, 12 of April 2008, Tilman Schmidt wrote:
> > On Fri, 11 Apr 2008 15:58:42 -0400, Valdis.Kletnieks@vt.edu wrote:
> > > On Thu, 10 Apr 2008 21:23:54 EDT, Mark Lord said:
> > > 
> > >> You still keep refering to it as "your (my) bug".
> > >> It's not.  I had nothing to do with it, other than stumbling over it.
> > > 
> > > Like it or not, when you're the owner of the only box that can reliably
> > > reproduce an error condition, it's your bug.
> > 
> > Thanks for the advice. I'll keep it in mind next time I have to decide
> > whether to report a bug I'm stumbling over.
> 
> Well, the fact is, reporting bugs is always welcome.
> 
> However, it may not be immediately obvious what causes the bug to appear
> as well as the bug need not be readily reproducible on any other system than
> yours, at least at the moment.
> 
> In which case whether or not the bug will be fixed depends on the reporter.
> Namely, if the reporter wants and has the time to provide developers with
> additional information, the bug has a good chance to be fixed.  Otherwise,
> it'll probably stay there until there's a more persistent reporter or it's
> fixed as a result of a related change.
> 
> So, if people ask you to do a bisection, they probably mean "we don't see
> what the problem is and can't reproduce it, so please get us more information,
> otherwise we won't know how to fix it".  In that case, you could provide them
> with a reproducible test case just as well.
> 
> That said, there may be some developers who just don't want to spend time on
> analysing code and put the burden of finding the offending change on the
> reporter, but I don't think it's common practice.

Very true. One other thing which might get confusing/frustrating on the
user side is that currently, Linux is the *only* product which requires
the bug reporter to find the fault change (yes, I know, it's scalable).
All other products the reporter uses work differently: the reporter
contacts the editor/author/support/... and briefly describes his problem.
Support asks him for a bit more details, remains silent for some time,
then comes up with a patched version to confirm that the bug is fixed.

So it is understandable from the user's standpoint that Linux appears
quite complex to report bugs. But we should remind users that LKML is
*not* a place to get free kernel support, but it's a *development*
mailing list, and that it is somewhat expected that developers ask
reporters for more development related contribution.

But if the reporter does not want to/cannot do much more, we should
not aggress him, and point it to other places instead (eg: at least
create an entry in bugzilla so that their report is not lost, and
they have a chance to get contacted when the fix is known).

Regards,
Willy

