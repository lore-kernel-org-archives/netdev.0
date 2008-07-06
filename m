From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 8/8] benet: Kconfig, Makefile, MAINTAINERS
Date: Sun, 6 Jul 2008 10:41:30 -0700
Message-ID: <20080706104130.8044ec03.randy.dunlap@oracle.com>
References: <20080704165755.1c3a284c@mailhost.serverengines.com>
	<20080705013933.91175119.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Subbu Seetharaman" <subbus@serverengines.com>, jeff@garzik.org,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21746 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759950AbYGFRlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 13:41:45 -0400
In-Reply-To: <20080705013933.91175119.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 5 Jul 2008 01:39:33 -0400 Bill Fink wrote:

> On Fri, 04 Jul 2008, Subbu Seetharaman wrote:
> 
> > Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
> > ---
> >  MAINTAINERS          |    7 +++++++
> >  drivers/net/Kconfig  |    8 ++++++++
> >  drivers/net/Makefile |    1 +
> >  3 files changed, 16 insertions(+), 0 deletions(-)
> 
> ...
> 
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index f4182cf..78b4d6e 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -2581,6 +2581,14 @@ config BNX2X
> >  
> >  source "drivers/net/sfc/Kconfig"
> >  
> > +config BENET
> > +	tristate "ServerEngines 10Gb NIC - BladeEngine"
> > +	depends on PCI
> > +	select INET_LRO
> > +	help
> > +	  This driver implements the NIC functionality for ServerEngines
> > +	  10Gb network adapter BladeEngine (EC 3210).
> > +
> >  endif # NETDEV_10000
> >  
> >  source "drivers/net/tokenring/Kconfig"
> 
> I'm no Kconfig expert, but based on previous driver discussions,
> I believe the above depends needs to be changed to:
> 
> 	depends on PCI && INET
> 
> to prevent certain build problems that can arise from having just
> the "select INET_LRO" clause.

Correct.  Thanks for catching that.

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
