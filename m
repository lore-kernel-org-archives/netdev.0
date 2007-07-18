From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Wed, 18 Jul 2007 17:18:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707181712340.16513@localhost.localdomain>
References: <469E75AA.7040109@pimpmylinux.org>
 <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
 <20070718134012.cde2f956.randy.dunlap@oracle.com> <469E7BE1.6090401@garzik.org>
 <Pine.LNX.4.64.0707181648330.15343@localhost.localdomain>
 <20070718210903.GM3801@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Gabriel C <crazy@pimpmylinux.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:52456 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757498AbXGRVVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 17:21:24 -0400
In-Reply-To: <20070718210903.GM3801@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007, Adrian Bunk wrote:

> On Wed, Jul 18, 2007 at 04:51:33PM -0400, Robert P. J. Day wrote:
> > On Wed, 18 Jul 2007, Jeff Garzik wrote:
> >
> > > Randy Dunlap wrote:
> > > > On Wed, 18 Jul 2007 16:23:09 -0400 (EDT) Robert P. J. Day wrote:
> > > > > there's no point adding all that redundant content when it can all be
> > > > > done automatically.
> > > >
> > > > I like it.  Are there any kconfig patches to support this plan?
> > >
> > > Speaking specifically to adding 'EXPERIMENTAL', I distinctly
> > > remember at some point in the past the config system was smart
> > > enough to print " (EXPERIMENTAL)" if that entry depended on
> > > CONFIG_EXPERIMENTAL.
> > >
> > > We should head in that direction.
> >
> > there's one point i want to re-iterate.  i'd prefer to see
> > EXPERIMENTAL stop being a dependency, as in:
> >
> >   depends on SNAFU && FUBAR && EXPERIMENTAL
> >
> > "EXPERIMENTAL" is not a dependency in the true sense of the word
> > -- it is more of an attribute, and i think it would far more sense
> > to see entries like:
> >
> >   depends on SNAFU && FUBAR
> >   maturity EXPERIMENTAL
>
> Plus some special case in the kconfig code that you can somewhere
> select the maturity levels you want to use (currently it's a normal
> option kconfig doesn't have to know anything about).

i already described that here:

http://readlist.com/lists/vger.kernel.org/linux-kernel/66/334172.html

where the top-level config would look something like:

[*] Activate maturity attributes
  [*] EXPERIMENTAL
  [*] DEPRECATED
  [*] OBSOLETE
  [*] BROKEN

whereupon you could select any combination of the attributes you want
displayed *beyond the regular ones* during the config process.

> Remind me, would there be any big advantage after such a change
> besides being able to automatically print " (EXPERIMENTAL)" at the
> end of the prompt?

defining a new Kconfig attribute means you can process it differently
from regular dependencies.  and if it's added as a general feature, it
can be used for other possible attributes beyond just a maturity
level.

if you leave these maturity levels as regular dependencies, you're
going to have to brute force and manually process them, and why make
it that ugly?

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
