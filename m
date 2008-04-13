From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Reporting bugs and bisection (was: Re: 2.6.25-rc8: FTP transfer errors)
Date: Mon, 14 Apr 2008 00:21:18 +0400
Message-ID: <20080413202118.GA29658@2ka.mipt.ru>
References: <47FEADCB.7070104@rtr.ca> <22880.1207943922@turing-police.cc.vt.edu> <47FFE5DA.8000709@imap.cc> <200804132040.12138.rjw@sisk.pl> <20080413184730.GD8474@1wt.eu> <20080413121831.d89dd424.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48090 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754737AbYDMUWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 16:22:51 -0400
Content-Disposition: inline
In-Reply-To: <20080413121831.d89dd424.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, Apr 13, 2008 at 12:18:31PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> >  One other thing which might get confusing/frustrating on the
> > user side is that currently, Linux is the *only* product which requires
> > the bug reporter to find the fault change
> 
> That's because many (probably most) Linux bugs are dependent upon the
> hardware which they run on, and developers cannot reproduce the failure on
> their hardware.  Other software products don't have that problem.

Bugs are bugs, they either depend on hardware or do not. 
There is no perfect world where after reporting subtle bug it will be
fixed. It is not Linux, it is everywhere. Bugs are only fixed when
they have major impact. Only. Either by having exploit, or crash,
or good testcase. Or bisect result.

This just a tool to help both parties. And a huge help for regressions.
If bug would exist for years, bisection unlikely to help.
 
> That being said..  four or five years ago, developers would often work
> closely with the reporter working out why the reporter's failure was
> occurring.  Several days of back-and-forth.

Yeah, spent two weeks kicking all possible stuff around and eventually
drop that namespace patch at all to find where the problem was. We
started to move further.

Bisect is just a tool. It is not something developers throw into user
when they do not want to work. This _is_ a help, which allows both to
solve problem in the fastest way.

If the same would be done on developers machine and huge patches would
be sent to jump between changesets, that would be a real 'work closely
with the reporter working out why the reporter's failure was occurring'?

You pointed it yourself: several days of back-and-forth.
With this helping automation tool called bisect bug was resolved in 15
minutes after completion. Completion itself took couple of hours.

> We dont' do that as much nowadays - there's a tendency to
> 
> a) throw the problem back at the reporter, often asking them to bisect. 
>    If the reporter is running a distro kernel (eg: Fedora) then that's
>    quite hard, and often isn't a think they have knowledge to do.  So
>    they'll just disappear.  Or
> 
> b) just ignore the report altogether.

There is also global warming tendency. IIRC.

Bugs _are_ fixed, Andrew. And developers did not change suddenly to
selfish bastards who do not care for users. They just developed a tool,
which greatly helps to both and saves lots of users time, since
regression gets fixed with this tool really quickly. Bisect is not asked
to be performed without a reason. For subtle bug it is the fastest way,
but otherwise there might be a long conversation. And even in this
really subtle case there was a dialog.

Bisect automation does not add kind relations though, but we can ask
Linus to add couple of smiles into the output.

-- 
	Evgeniy Polyakov
