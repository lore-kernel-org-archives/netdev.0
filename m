From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: Re: [PATCH] using mii-bitbang on different processor ports -
	update the booting-without-of.txt-file
Date: Wed, 07 Nov 2007 14:40:44 +0100
Message-ID: <1194442844.3571.14.camel@p60635-ste.ids.de>
References: <1194339117.3467.8.camel@p60635-ste.ids.de>
	 <20071106184649.GA5283@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares.ids.de ([213.144.29.131]:49467 "EHLO ares.ids.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326AbXKGNkq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 08:40:46 -0500
Received: from ares.ids.de (ares.ids.de [127.0.0.1])
	by ares.ids.de (PGP Universal) with ESMTP id A138CF491A6
	for <netdev@vger.kernel.org>; Wed,  7 Nov 2007 14:40:44 +0100 (CET)
In-Reply-To: <20071106184649.GA5283@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 06.11.2007, 12:46 -0600 schrieb Scott Wood:
> >  
> > +   The "reg"-property may have also depending on board design
> > +   the following form:
> > +	reg = <10d40 14 10d60 14>;
> > +   In that case the pin for mdio data controlling is on the port C,
> > +   and the pin for mdio clock controlling is on the port D.
> 
> It'd be better to explicitly say that the first resource is mdio, and the
> second resource is mdc, rather than require the reader to know/look up which
> corresponds to 10d40 and which to 10d60.
> 
> -Scott

Ok. What would you say about something like that:
--
If both mdio and mdc controlling pins are on the same processor port,
one resource should be used.
Otherwise, two resources are used: the 1-st - mdio, the 2-nd - mdc.
--
Please, correct me, if it sounds bad.

Thanks and regards
Sergej. 
