From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 09:40:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804110849520.28360@wrl-59.cs.helsinki.fi>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net>
 <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net>
 <47FEBDAA.7010305@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	tilman@imap.cc, yoshfuji@linux-ipv6.org,
	Jeff Garzik <jeff@garzik.org>, rjw@sisk.pl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35360 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbYDKGkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 02:40:14 -0400
In-Reply-To: <47FEBDAA.7010305@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Apr 2008, Mark Lord wrote:

> David Miller wrote:
> > From: Mark Lord <lkml@rtr.ca>
> > Date: Thu, 10 Apr 2008 20:27:14 -0400
> > 
> > > It's *your* bug -- you signed off on the commit.
> > 
> > I sign off on basically every networking commit, does that mean I have
> > to fix every networking bug and every networking bug is "mine"?
> ..
> 
> Absolutely, though to a varying degree.  That's the responsibility
> that goes with the role of a subsystem maintainer.  I once had
> such a role, and gave it up when I felt I could no longer keep up.  
> You still keep refering to it as "your (my) bug".
> It's not.  I had nothing to do with it, other than stumbling over it.

This bug is perfect example where bisect clearly was useful :-). Nobody 
knew whose bug it actually was until your bisect gave directions.

> When people stumble over a libata bug, I look hard to see if my code
> could possibly cause it.  Jeff looks even harder, because he's the
> current subsystem dude for libata.
>
> I never suggest a user search through a mountain of unrelated commits
> for something I've screwed up on.

But it is ok for you to ask an innocent net developer to do that (even 
with your terms as I hadn't signed off _anything_ related to that one),
hmm?

...You had this pretty demanding tone earlier:

> Or I can ignore it, like the net developers, since I have a workaround.
> And then we'll see what other apps are broken upon 2.6.25 final release.
>
> Really, folks.  Bug reports are intended to *help* the developers,
> not something to be thrown back in their faces.
>
> There do seem to have been a *lot* of changes around the tcp closing/close
> code (as I see from diff'ing 2.6.24 against latest -git).
>
> *Somebody* is responsible for those changes.
> That particular *somebody* ought to volunteer some help here,
> reducing the mountain of commits to a big handful or two.

...and also...

> > Anyways, here's five hours of free consulting for you

...Sure I could use similar words, but you might use the not-mine
bug approach again to deflect... :-( ...No, I don't mind really :-).
I well understand that I occassionally end up chasing things 
which are bugs that other people have caused, that's part of the
game.

> I give more directed help, patches to collect more relevant information, 
> and patches to try and resolve it.

Now that you have, as stated earlier, first looked the diffs (tcp*.c stuff 
mainly I suppose?!?), and the bisected it and found the breaker, and even 
patch is available already... Seriously, knowing all what's now available, 
how could we have solved _this particular case_ without that very useful 
help (bisect) from your side?

Yes, I went through the commit list (maybe you did as well), I'm not sure 
if Dave did as well. In addition, I checked a number of individual diffs 
too but this just isn't something very obvious (I have to admit though 
that I don't really understand all those namespace things, so I didn't 
even know how to look them too carefully).


-- 
 i.
