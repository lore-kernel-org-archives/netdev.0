From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Tue, 5 Jun 2007 00:41:46 +0200
Message-ID: <20070604224146.GE2711@elf.ucw.cz>
References: <200706031237.36773.rjw@sisk.pl> <20070604111112.GP4363@elf.ucw.cz> <200706041549.11277.rjw@sisk.pl> <1180991794.4356.31.camel@nigel.suspend2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-pm <linux-pm@lists.osdl.org>, netdev@vger.kernel.org,
	Valerie Henson <val@nmt.edu>, Peer Chen <peer.chen@uli.com.tw>
To: Nigel Cunningham <nigel@nigel.suspend2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:51200 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756886AbXFDWlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 18:41:52 -0400
Content-Disposition: inline
In-Reply-To: <1180991794.4356.31.camel@nigel.suspend2.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > > > +#endif /* CONFIG_PM */
> > > 
> > > > @@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_driver 
> > > >  	.id_table	= uli526x_pci_tbl,
> > > >  	.probe		= uli526x_init_one,
> > > >  	.remove		= __devexit_p(uli526x_remove_one),
> > > > +#ifdef CONFIG_PM
> > > > +	.suspend	= uli526x_suspend,
> > > > +	.resume		= uli526x_resume,
> > > > +#endif
> > > 
> > > ...so that this ifdef is not needed?
> > 
> > OK, why not.
> 
> Because it's uglier and #ifdef is the established way of doing things?

Actually the way I suggested is nicer, IIRC akpm invented it. It keeps
ifdefs localized around the block that _needs_ to be ifdefed.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
