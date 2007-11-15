From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 15 Nov 2007 16:09:38 +0100
Message-ID: <20071115150938.GA22825@uranus.ravnborg.org>
References: <20071114121339.25823.0@janus.isnogud.escape.de> <20071114121425.25823.2@janus.isnogud.escape.de> <20071114133837.6b899595@freepuppy.rosehill> <ygfr6irbv19.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs.thuermann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:36594 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752495AbXKOPIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 10:08:10 -0500
Content-Disposition: inline
In-Reply-To: <ygfr6irbv19.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > +
> > > +struct timer_list stattimer; /* timer for statistics update */
> > > +struct s_stats  stats;       /* packet statistics */
> > > +struct s_pstats pstats;      /* receive list statistics */
> > 
> > More global variables without prefix.
> 
> These variables are not exported with EXPORT_SYMBOL, so there should
> be no name conflict.  They cannot be made static because they are used
> in af_can.c and proc.c.  Nevertheless we can prefix them with can_ if
> you still think it's necessary.

When this is build-in they will be in the global kernel namespace.
So please add can_ prefix.

	Sam
