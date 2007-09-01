From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Sat, 1 Sep 2007 06:44:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0709010641540.31472@localhost.localdomain>
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
Cc: Simon Arlott <simon@fire.lp0.eu>, Sam Ravnborg <sam@ravnborg.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>, Jeff Garzik <jeff@garzik.org>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:35613 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbXIAK5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 06:57:05 -0400
In-Reply-To: <20070831102527.09fb42c0.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Aug 2007, Randy Dunlap wrote:

> On Thu, 19 Jul 2007 23:05:57 +0100 Simon Arlott wrote:

> > What about something like this? I'm not sure if the addition to
> > sym_init is desirable... I also had to prefix _ to the name for
> > now otherwise it conflicts badly with the current symbols. It
> > probably should stop "depends on _BROKEN" etc. too.
>
> Hi Simon,
>
> (sorry for the delay)
>
> I like this patch very much... I just can't get it to build (on
> 2.6.23-rc4).

i got a patch from simon a while back, and it failed with
"shift/reduce" conflicts.  is that what you're seeing?

> >  	while (1) {
> >  		printf("%*s%s ", indent - 1, "", menu->prompt->text);
> > +		switch (sym->maturity) {
> > +		case M_EXPERIMENTAL:
> > +			printf("(EXPERIMENTAL) ");
> > +			break;
> > +		case M_DEPRECATED:
> > +			printf("(DEPRECATED) ");
> > +			break;
> > +		case M_OBSOLETE:
> > +			printf("(OBSOLETE) ");
> > +			break;
> > +		case M_BROKEN:
> > +			printf("(BROKEN) ");
> > +			break;
> > +		default:
> > +			break;
> > +		}
> >  		if (sym->name)
> >  			printf("(%s) ", sym->name);
> >  		type = sym_get_type(sym);

for now, simon, why not just reduce this to supporting only DEPRECATED
and OBSOLETE so that it can be at least tested as "proof of concept?"

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
