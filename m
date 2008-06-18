From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Wed, 18 Jun 2008 07:00:53 +0200
Message-ID: <20080618050053.GA19359@uranus.ravnborg.org>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com> <48581188.90102@freescale.com> <20080617195739.GB13147@uranus.ravnborg.org> <485818AA.8090701@freescale.com> <20080617210055.GA13468@uranus.ravnborg.org> <485828B0.4010101@freescale.com> <Pine.LNX.4.64.0806171648300.7584@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Wood <scottwood@freescale.com>,
	John Rigby <jrigby@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:46711 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886AbYFRFAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 01:00:11 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806171648300.7584@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >
> >I'm not sure I understand what you're looking for, but I don't see 
> >anything wrong with something like this (apart from missing help text):
> >
> >config FS_ENET
> >	 bool
> >	 select MII
> >	 select PHYLIB
> >
> >config FS_ENET_HAS_SCC
> >	 bool "Freescale CPM SCC Ethernet"
> >	 depends on CPM1 || CPM2
> >	 select FS_ENET
> 
> What prevents me from turning on FS_ENET_HAS_SCC without MII or PHYLIB?
Nothing.
But if set FS_ENET_HAS_SCC to 'y' then kconfig will select FS_ENET
which again will select MII and PHYLIB.

	Sam
