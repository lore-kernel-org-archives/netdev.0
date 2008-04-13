From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Reporting bugs and bisection (was: Re: 2.6.25-rc8: FTP transfer errors)
Date: Sun, 13 Apr 2008 20:40:11 +0200
Message-ID: <200804132040.12138.rjw@sisk.pl>
References: <47FEADCB.7070104@rtr.ca> <22880.1207943922@turing-police.cc.vt.edu> <47FFE5DA.8000709@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:36629 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbYDMSj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 14:39:58 -0400
In-Reply-To: <47FFE5DA.8000709@imap.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, 12 of April 2008, Tilman Schmidt wrote:
> On Fri, 11 Apr 2008 15:58:42 -0400, Valdis.Kletnieks@vt.edu wrote:
> > On Thu, 10 Apr 2008 21:23:54 EDT, Mark Lord said:
> > 
> >> You still keep refering to it as "your (my) bug".
> >> It's not.  I had nothing to do with it, other than stumbling over it.
> > 
> > Like it or not, when you're the owner of the only box that can reliably
> > reproduce an error condition, it's your bug.
> 
> Thanks for the advice. I'll keep it in mind next time I have to decide
> whether to report a bug I'm stumbling over.

Well, the fact is, reporting bugs is always welcome.

However, it may not be immediately obvious what causes the bug to appear
as well as the bug need not be readily reproducible on any other system than
yours, at least at the moment.

In which case whether or not the bug will be fixed depends on the reporter.
Namely, if the reporter wants and has the time to provide developers with
additional information, the bug has a good chance to be fixed.  Otherwise,
it'll probably stay there until there's a more persistent reporter or it's
fixed as a result of a related change.

So, if people ask you to do a bisection, they probably mean "we don't see
what the problem is and can't reproduce it, so please get us more information,
otherwise we won't know how to fix it".  In that case, you could provide them
with a reproducible test case just as well.

That said, there may be some developers who just don't want to spend time on
analysing code and put the burden of finding the offending change on the
reporter, but I don't think it's common practice.

Thanks,
Rafael
