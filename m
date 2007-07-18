From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Wed, 18 Jul 2007 16:51:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707181648330.15343@localhost.localdomain>
References: <469E75AA.7040109@pimpmylinux.org>
 <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
 <20070718134012.cde2f956.randy.dunlap@oracle.com> <469E7BE1.6090401@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Gabriel C <crazy@pimpmylinux.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:51510 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbXGRUxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 16:53:37 -0400
In-Reply-To: <469E7BE1.6090401@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007, Jeff Garzik wrote:

> Randy Dunlap wrote:
> > On Wed, 18 Jul 2007 16:23:09 -0400 (EDT) Robert P. J. Day wrote:
> > > there's no point adding all that redundant content when it can all be
> > > done automatically.
> >
> > I like it.  Are there any kconfig patches to support this plan?
>
> Speaking specifically to adding 'EXPERIMENTAL', I distinctly
> remember at some point in the past the config system was smart
> enough to print " (EXPERIMENTAL)" if that entry depended on
> CONFIG_EXPERIMENTAL.
>
> We should head in that direction.

there's one point i want to re-iterate.  i'd prefer to see
EXPERIMENTAL stop being a dependency, as in:

  depends on SNAFU && FUBAR && EXPERIMENTAL

"EXPERIMENTAL" is not a dependency in the true sense of the word -- it
is more of an attribute, and i think it would far more sense to see
entries like:

  depends on SNAFU && FUBAR
  maturity EXPERIMENTAL

sure, it's more work, but i think the cost is worth it in terms of
flexibility (particularly if *i'm* not the one doing the work. :-)

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
