From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] natsemi: make cable length magic configurable
Date: Mon, 16 Jul 2012 14:57:40 +0100
Message-ID: <20120716135740.GB22600@sirena.org.uk>
References: <201111241443.59191.jdelvare@suse.de>
 <1322162739.2784.26.camel@bwh-desktop>
 <1342441581.4165.235.camel@amber.site>
 <1342444134.2523.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Delvare <jdelvare@suse.de>, netdev@vger.kernel.org,
	Tim Hockin <thockin@hockin.org>, Olaf Kirch <okir@suse.de>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:46012 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab2GPN5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 09:57:44 -0400
Content-Disposition: inline
In-Reply-To: <1342444134.2523.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 02:08:54PM +0100, Ben Hutchings wrote:
> On Mon, 2012-07-16 at 14:26 +0200, Jean Delvare wrote:

> > Furthermore I don't quite get why we can't just go with the module
> > parameter. As I understand it, this is a crappy driver for crappy, rare
> > hardware. The driver already has a module parameter to work around a
> > hardware bug (dspcfg_workaround), I don't quite see why adding a second
> > one would be a problem. At least it is consistent.

> David can be quite insistent about finding an alternative to module
> parameters.

The hardware isn't that rare or bad - it's pretty widely deployed in
100Mbit systems (including lots of embedded ones) and performs well for
the systems it's targetting.  You'd not use it for a modern server but
if what you need is 100M it's a fairly good part.

The dspcfg_workaround change was added for one specific board, I'd be
really surprised if it were useful for anything other than the board it
was originally developed for, I'd not be surprised to learn that it's a
hardware issue in that board.  It disables a documented erratum
workaround to give a performance improvement, it was done for one board
that for some reason triggered the erratum a lot but with less severe
consequences than normal.
