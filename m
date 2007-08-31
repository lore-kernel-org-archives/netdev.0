From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Fri, 31 Aug 2007 13:23:53 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0708311318220.18158@localhost.localdomain>
References: <469E75AA.7040109@pimpmylinux.org>
 <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
 <20070718134012.cde2f956.randy.dunlap@oracle.com> <469E7BE1.6090401@garzik.org>
 <Pine.LNX.4.64.0707181648330.15343@localhost.localdomain>
 <20070718210903.GM3801@stusta.de> <Pine.LNX.4.64.0707181712340.16513@localhost.localdomain>
 <20070719054742.GN3801@stusta.de> <Pine.LNX.4.64.0707190331330.11902@localhost.localdomain>
 <469F240E.9040205@s5r6.in-berlin.de> <Pine.LNX.4.64.0707190523001.19216@localhost.localdomain>
 <20070719083109.13b2ab56.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0707191213130.8844@localhost.localdomain>
 <469FE045.3070403@simon.arlott.org.uk> <20070831102527.09fb42c0.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Arlott <simon@fire.lp0.eu>, sam@ravnborg.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>, Jeff Garzik <jeff@garzik.org>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:37307 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965436AbXHaRit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 13:38:49 -0400
In-Reply-To: <20070831102527.09fb42c0.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Aug 2007, Randy Dunlap wrote:

> On Thu, 19 Jul 2007 23:05:57 +0100 Simon Arlott wrote:
>
> > On 19/07/07 17:19, Robert P. J. Day wrote:
> > > On Thu, 19 Jul 2007, Randy Dunlap wrote:
> > >> I think that Stefan means a patch to the kconfig source code,
> > >> not the the Kconfig files.  Good luck.  I'd still like to see it.
> > >
> > > yes, i understand what he wanted now.  as a first step (that
> > > theoretically shouldn't change any behaviour), i'd patch the Kconfig
> > > structure to add a new attribute ("maturity") which would be allowed
> > > to be set to *exactly one* of a pre-defined set of values (say,
> > > OBSOLETE, DEPRECATED, EXPERIMENTAL, and STILLBLEEDING).  and that's
> > > it, nothing more.
> > >
> > > don't try to do anything with any of that just yet, just add the
> > > infrastructure to support the (optional) association of a maturity
> > > level with a config option.  that's step one.
> >
> > What about something like this? I'm not sure if the addition to sym_init
> > is desirable... I also had to prefix _ to the name for now otherwise it
> > conflicts badly with the current symbols. It probably should stop
> > "depends on _BROKEN" etc. too.

i'm sure i'm going to get shouted down here, but i really disagree
with "BROKEN" being considered a "maturity level".  IMHO, things like
EXPERIMENTAL, DEPRECATED and OBSOLETE represent maturity levels, for
what i think are obvious reasons.

something like BROKEN, though, has *nothing* to do with maturity.  a
feature can be any of those maturity levels, and simultaneously be
BROKEN.  i consider BROKEN to be what i call a "status", and different
status levels might be the default of normal, or KIND_OF_FLAKY or
TOTALLY_BORKED -- that's where BROKEN would fit in.

*please* don't start mixing these different attributes.  it's just
going to make an irreversible mess of things.  leave BROKEN out of
this for the time being.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
