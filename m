From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Top kernel oopses/warnings for the week of October 7th, 2008
Date: Wed, 8 Oct 2008 11:21:36 +0200
Message-ID: <20081008092136.GA22387@elte.hu>
References: <48EBBE15.9030905@linux.intel.com> <20081007235833.1a89948f@lxorguk.ukuu.org.uk> <20081007.160835.257227518.davem@davemloft.net> <200810081106.55730.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	arjan@linux.intel.com, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org, tglx@tglx.de,
	tytso@mit.edu, linux-ide@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:56623 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752832AbYJHJWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 05:22:34 -0400
Content-Disposition: inline
In-Reply-To: <200810081106.55730.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Rafael J. Wysocki <rjw@sisk.pl> wrote:

> On Wednesday, 8 of October 2008, David Miller wrote:
> > From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> > Date: Tue, 7 Oct 2008 23:58:33 +0100
> > 
> > > > This should have been fixed by:
> > > > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=f5a6d958b5d0a10e7e7a9dee1862fb31d08c6d26
> > > 
> > > You mean - hidden by - that change should IMHO be reverted
> > 
> > Grrr... I totally agree.
> 
> Even though they are false positives in many cases?
> 
> (Yes, they are).

it's your judgement call i guess - i just wanted to challenge the 
terminology of calling it a fix ;-)

Can you think of any good way of reintroducing the good aspect of the 
WARN(), without the false positives? [ If not, and if the WARN()s do 
more harm than good then it's the right change. ]

But generally the trend is the opposite direction: we try to add as many 
WARN()s as possible, and we need even more good WARN()s in the kernel. 
When we meet false positives we try to improve the quality/yield of the 
warning, not eliminate it.

Granted, they are a bit embarrassing when they show up in the top 10 but 
they are also very helpful and are tracked very nicely and lead to 
actual bugfixes that _matter_.

Kerneloops.org is a wonderful tool: it enables a broad spectrum of users 
to help us out with their feedback, without them being forced into any 
manual work, and without them having to understand the kernel bug 
reporting workflow. Its scale is already enormous: 3000+ bugs reported 
per week. (many kudos Arjan!)

Once its growth stabilizes (all the large distros have it either enabled 
today or have the client in their pipeline) we can even observe 
long-term trends and estimate release-to-release suckiness. That was 
impossible before and maintainers were left largely to imprecise 
intuitive guesses about where we stand wrt. kernel quality.

	Ingo
