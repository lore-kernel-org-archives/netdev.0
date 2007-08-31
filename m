From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Fri, 31 Aug 2007 17:00:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0708311656360.27345@localhost.localdomain>
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
 <Pine.LNX.4.64.0708311318220.18158@localhost.localdomain> <46D858A9.4080506@garzik.org>
 <20070831131612.312664ef.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, Simon Arlott <simon@fire.lp0.eu>,
	sam@ravnborg.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:43921 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761114AbXHaVNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 17:13:40 -0400
In-Reply-To: <20070831131612.312664ef.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Aug 2007, Randy Dunlap wrote:

> What I like about the patch is that it associates some kconfig
> symbol with prompt strings, so that we don't have to edit
> "(EXPERIMENTAL)" all the darn time (e.g.).
>
> I'd be quite happy with calling it "status" rather than "maturity",
> and with being able to use multiple of the status tags at one time,
> such as
>
> 	config FOO
> 	depends on BAR
> 	status OBSOLETE BROKEN

grrrrrrrr ... i already made my point in my earlier post.  i'd
really, really like it if *this* attribute remained as "maturity".  an
entirely *separate* attribute could be defined as a feature "status",
which would be entirely orthogonal to maturity level, so that the
above would be written as

	maturity OBSOLETE
	status BROKEN

there's a reason for this -- any feature should have exactly *one*
value for any attribute.  that is, in terms of maturity, a feature
could be EXPERIMENTAL *or* DEPRECATED *or* OBSOLETE.  it ***can't***
be more than one, as in both DEPRECATED *and* OBSOLETE.  to allow that
flexibility is to descend into absurdity.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
