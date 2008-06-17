From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Tue, 17 Jun 2008 21:57:39 +0200
Message-ID: <20080617195739.GB13147@uranus.ravnborg.org>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com> <48581188.90102@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Rigby <jrigby@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:48082 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745AbYFQT4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 15:56:54 -0400
Content-Disposition: inline
In-Reply-To: <48581188.90102@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 02:33:28PM -0500, Scott Wood wrote:
> John Rigby wrote:
> > config FS_ENET
> >        tristate "Freescale Ethernet Driver"
> >-       depends on CPM1 || CPM2
> >+       depends on CPM1 || CPM2 || FS_ENET_MPC5121_FEC
> >        select MII
> >        select PHYLIB
> > 
> >+config FS_ENET_MPC5121_FEC
> >+	bool "Freescale MPC512x FEC driver"
> >+	depends on PPC_MPC512x
> >+	select FS_ENET
> >+	select PPC_CPM_NEW_BINDING
> >+	default y
> 
> No default y.
I by the way do not see the need for the prompt of FS_ENET.
Do you ever want to change it if one of the dependencies
are selected?

	Sam
