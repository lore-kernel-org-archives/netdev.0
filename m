From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: {Spam?} Re: {Spam?} Re: {Spam?} [PATCH] NET: Remove obsolete traffic shaper
 code.
Date: Sun, 15 Apr 2007 09:37:42 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0704150921410.24386@localhost.localdomain>
References: <Pine.LNX.4.64.0704141925310.22138@localhost.localdomain>
 <5640c7e00704141646k44334de9g99dc509bf96bac5f@mail.gmail.com>
 <Pine.LNX.4.64.0704141959190.22316@localhost.localdomain>
 <5640c7e00704141948n5f82cd8fl64092c720954175f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:48240 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbXDONks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2007 09:40:48 -0400
In-Reply-To: <5640c7e00704141948n5f82cd8fl64092c720954175f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Apr 2007, Ian McDonald wrote:

> On 4/15/07, Robert P. J. Day <rpjday@mindspring.com> wrote:
> > in fact, according to this:
> >
> > http://lkml.org/lkml/2006/1/13/139
> >
> > that notice was put in the feature removal file well over a year ago,
> > during 2.6.15.  so that would seem to be more than adequate time for
> > everyone to prepare for it.  but it must have been deleted from that
> > file since then as well.
>
> Yes and that was never merged and so was resent on January 19th, 2006:
> http://www.nabble.com/-2.6-patch--schedule-SHAPER-for-removal-t949871.html
>
> At that point people debated about it being too short notice and the
> patch never went in.
>
> I therefore think we can't just remove with NO notice.

  i have no dog in this fight one way or the other.  i was just in a
housecleaning mood and the shaper stuff looked old and relatively
dead, that's all.  if there's a good reason to keep it, fine.

  but it seems fairly clear that this *is* a dead feature:

===================================================
$ git show 3b6a792f6ace33584897d1af08630c9acc0ce221
commit 3b6a792f6ace33584897d1af08630c9acc0ce221
Author: Jiri Slaby <jirislaby@gmail.com>
Date:   Mon Nov 6 14:34:48 2006 -0800

    [NET]: kconfig, correct traffic shaper

    As Patrick McHardy <kaber@trash.net> suggested, Traffic Shaper is now
    obsolete and alternative to it is no longer CBQ, since its problems with
    virtual devices, alter Kconfig text to reflect this -- put a link to the
    traffic schedulers as a whole.

    Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
    Acked-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>
==================================================

  so given that the discussion of getting rid of this feature started
well over a year ago, coupled with the fact that its own Kconfig entry
has listed it as "OBSOLETE" for over five months now, plus that it has
very few references left in the tree, well, maybe it's not outrageous
to think that it really can be tossed.

  but, like i said, i have no vested interest in this one way or the
other, except for a fondness for getting rid of dead stuff.

rday

p.s.  if it shouldn't be removed, maybe someone would like to add an
entry to the feature removal file for it.
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
