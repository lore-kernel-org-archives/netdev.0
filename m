From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Tue, 17 Jun 2008 16:52:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806171648300.7584@t2.domain.actdsltmp>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com>
 <48581188.90102@freescale.com> <20080617195739.GB13147@uranus.ravnborg.org>
 <485818AA.8090701@freescale.com> <20080617210055.GA13468@uranus.ravnborg.org>
 <485828B0.4010101@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Sam Ravnborg <sam@ravnborg.org>, John Rigby <jrigby@freescale.com>,
	linuxppc-dev@ozlabs.org, jeff@garzik.org, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:61793 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758380AbYFQXxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:53:07 -0400
In-Reply-To: <485828B0.4010101@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jun 2008, Scott Wood wrote:
> Sam Ravnborg wrote:
>>  In general when you select a symbol that has dependencies you are almost
>>  always on the wrong track.
>
> more specific options should make sure that they never select it when the 
> dependencies aren't met.

Sure, in theory that would work, but in practice this ends up being a constant
source of broken builds.

>>  Use a dependency here with a sane default - then people can set it to 'n'
>>  if they really do not want this driver.
>>
>>  Spreading selects too much is just causing you pain in the long run.
>
> I'm not sure I understand what you're looking for, but I don't see anything 
> wrong with something like this (apart from missing help text):
>
> config FS_ENET
> 	 bool
> 	 select MII
> 	 select PHYLIB
>
> config FS_ENET_HAS_SCC
> 	 bool "Freescale CPM SCC Ethernet"
> 	 depends on CPM1 || CPM2
> 	 select FS_ENET

What prevents me from turning on FS_ENET_HAS_SCC without MII or PHYLIB?  Why
is FS_ENET_HAS_SCC a bool, and not tristate?
