From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Wed, 18 Jul 2007 16:44:00 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707181640100.14940@localhost.localdomain>
References: <469E75AA.7040109@pimpmylinux.org>
 <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
 <20070718134012.cde2f956.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Gabriel C <crazy@pimpmylinux.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:51258 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756776AbXGRUqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 16:46:21 -0400
In-Reply-To: <20070718134012.cde2f956.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007, Randy Dunlap wrote:

> On Wed, 18 Jul 2007 16:23:09 -0400 (EDT) Robert P. J. Day wrote:
>
> > On Wed, 18 Jul 2007, Gabriel C wrote:
> >
> > > Everything 'depends on' EXPERIMENTAL should be marked as such,
> > > visible in the menus.
> >
> > rather than add all that extraneous dreck to the Kconfig files, i
> > *really* wish folks would give serious thought to my earlier
> > suggestion about a "maturity level" attribute that could be used to
> > not only add a parenthesized maturity level during display, but could
> > also be used to activate/deactivate entire levels in one operation.
> >
> > there's no point adding all that redundant content when it can all be
> > done automatically.
>
> I like it.  Are there any kconfig patches to support this plan?

once upon a time, i'd proposed just adding a couple new "config"
entries, but i eventually decided that a better approach would be
to define a whole new Kconfig directive, as in:

config FUBAR
	maturity EXPERIMENTAL (or DEPRECATED or OBSOLETE or ...)

that would require extra processing in the parser, but it would allow
the "maturity" attribute to be used for all sorts of new and wacky
things, such as automatically displaying it at the end of a config
selection, or deselecting everything OBSOLETE in a build, etc.

how hard would it be to add processing like that to the Kconfig
infrastructure?

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
