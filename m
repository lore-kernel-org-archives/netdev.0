From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Thu, 10 Apr 2008 17:39:11 -0700 (PDT)
Message-ID: <20080410.173911.179180620.davem@davemloft.net>
References: <47FEADCB.7070104@rtr.ca>
	<20080410.172453.44434205.davem@davemloft.net>
	<47FEB062.3020003@rtr.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, tilman@imap.cc, yoshfuji@linux-ipv6.org,
	jeff@garzik.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: lkml@rtr.ca
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758217AbYDKAjY@vger.kernel.org>
In-Reply-To: <47FEB062.3020003@rtr.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Lord <lkml@rtr.ca>
Date: Thu, 10 Apr 2008 20:27:14 -0400

> It's *your* bug -- you signed off on the commit.

I sign off on basically every networking commit, does that mean I have
to fix every networking bug and every networking bug is "mine"?

Of course not, that doesn't scale at all.  What does scale is a
combination of good fully formed bug reports from users combined with
the efforts of the global developer pool.

Linus signs off on every patch from Andrew Morton he puts into the
tree, which is a lot, but does Linus work on every bug introduced by
one of those patches and are such bugs "his" bugs?  Of course he
doesn't, and of course not.  They get pushed up to the person
who wrote the patch once identified as such, and the patch is
reverted if the developer is unresponsive and this will have
consequences for patches they submit in the future.

I still think you have a very self-centered attitude about things.
This is about distributing effort, not forcing it upon individuals
or a constrained resource.

If I get hit by a bus, networking bugs would still get fixed if
handled properly.

And it's a win-win situation.  The incentive for a capable user to do
a bisect or whatever else is that if they do it their bug gets fixed
quickly.  That is the free market economy of Linux kernel bug
reporting.

It addresses the issue that in reality we'll never fix all bugs, and
therefore we prioritize.  And therefore if there is a bisected bug
report and also another one from a user who refuses to do that, guess
which bug gets worked on with a higher priority and which bug gets
fixed first?
