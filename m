From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Reporting bugs and bisection (was: Re: 2.6.25-rc8: FTP
	transfer errors)
Date: Mon, 14 Apr 2008 12:18:13 +0200
Message-ID: <20080414101813.GB14549@elte.hu>
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
Received: from mx3.mail.elte.hu ([157.181.1.138]:36765 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbYDNKSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 06:18:55 -0400
Content-Disposition: inline
In-Reply-To: <20080413121831.d89dd424.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> We dont' do that as much nowadays - there's a tendency to
> 
> a) throw the problem back at the reporter, often asking them to 
>    bisect. If the reporter is running a distro kernel (eg: Fedora) 
>    then that's quite hard, and often isn't a think they have knowledge 
>    to do.  So they'll just disappear.  Or
> 
> b) just ignore the report altogether.

hm, who does this - i've seen networking folks do it but does anyone 
else do it? Such cases are _clear_ abuse of users and they'll do the 
obvious thing: vote with their feet.

I only ask people to bisect it when all other avenues fail - and even 
then i try to make it clear that bisection is just something they can 
_optionally_ do to speed things up (it's never required), and that it's 
a pure opt-in.

doing _kernel_ bisection is totally hard at the moment - it disrupts the 
user way too much and causes many hours of work for most users. [ 
Requiring bisection for userspace projects might be more doable. (but 
even there's it's wrong when it's not automated completely and where a 
failure pattern is not deterministic.) ]

	Ingo
