From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Reporting bugs and bisection (was: Re: 2.6.25-rc8: FTP transfer errors)
Date: Sun, 13 Apr 2008 22:33:49 +0200
Message-ID: <200804132233.50491.rjw@sisk.pl>
References: <47FEADCB.7070104@rtr.ca> <20080413121831.d89dd424.akpm@linux-foundation.org> <20080413202118.GA29658@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:37257 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575AbYDMUd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 16:33:27 -0400
In-Reply-To: <20080413202118.GA29658@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, 13 of April 2008, Evgeniy Polyakov wrote:
> Hi.
> 
> On Sun, Apr 13, 2008 at 12:18:31PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > >  One other thing which might get confusing/frustrating on the
> > > user side is that currently, Linux is the *only* product which requires
> > > the bug reporter to find the fault change
> > 
> > That's because many (probably most) Linux bugs are dependent upon the
> > hardware which they run on, and developers cannot reproduce the failure on
> > their hardware.  Other software products don't have that problem.
> 
> Bugs are bugs, they either depend on hardware or do not. 
> There is no perfect world where after reporting subtle bug it will be
> fixed. It is not Linux, it is everywhere. Bugs are only fixed when
> they have major impact. Only. Either by having exploit, or crash,
> or good testcase. Or bisect result.
> 
> This just a tool to help both parties. And a huge help for regressions.
> If bug would exist for years, bisection unlikely to help.
>  
> > That being said..  four or five years ago, developers would often work
> > closely with the reporter working out why the reporter's failure was
> > occurring.  Several days of back-and-forth.
> 
> Yeah, spent two weeks kicking all possible stuff around and eventually
> drop that namespace patch at all to find where the problem was. We
> started to move further.
> 
> Bisect is just a tool. It is not something developers throw into user
> when they do not want to work. This _is_ a help, which allows both to
> solve problem in the fastest way.
> 
> If the same would be done on developers machine and huge patches would
> be sent to jump between changesets, that would be a real 'work closely
> with the reporter working out why the reporter's failure was occurring'?
> 
> You pointed it yourself: several days of back-and-forth.
> With this helping automation tool called bisect bug was resolved in 15
> minutes after completion. Completion itself took couple of hours.
> 
> > We dont' do that as much nowadays - there's a tendency to
> > 
> > a) throw the problem back at the reporter, often asking them to bisect. 
> >    If the reporter is running a distro kernel (eg: Fedora) then that's
> >    quite hard, and often isn't a think they have knowledge to do.  So
> >    they'll just disappear.  Or
> > 
> > b) just ignore the report altogether.
> 
> There is also global warming tendency. IIRC.
> 
> Bugs _are_ fixed, Andrew. And developers did not change suddenly to
> selfish bastards who do not care for users. They just developed a tool,
> which greatly helps to both and saves lots of users time, since
> regression gets fixed with this tool really quickly. Bisect is not asked
> to be performed without a reason.

To be honest, at least in one case no one reacted to my report(s) until I ran
a bisection and then it turned up an obviously broken patch.  The breakage
was so obvious that if anyone had actually looked at the code in question, he
would have see it immediately.

Things like this are very disappointing and have a very negative impact on bug
reporters.  We should do our best to avoid them.

Thanks,
Rafael
