From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/2 net-next] net: fec: add napi support to improve
 proformance
Date: Wed, 23 Jan 2013 08:53:23 +0100
Message-ID: <20130123075323.GU1906@pengutronix.de>
References: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
 <20130123072635.GO1906@pengutronix.de>
 <CAHrpEqQ3-prqJaCmt1hfOr4GzDVyuRNvko1SCyQZHdALhHkhkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Li <Frank.Li@freescale.com>, shawn.guo@linaro.org,
	B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45464 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870Ab3AWHx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 02:53:29 -0500
Content-Disposition: inline
In-Reply-To: <CAHrpEqQ3-prqJaCmt1hfOr4GzDVyuRNvko1SCyQZHdALhHkhkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 03:44:53PM +0800, Frank Li wrote:
> > This comment seems rather unnecessary. Also it should be
> >
> >         /* space left and right /*
> >
> > devicetree bindings should use '-' instead of '_'. The binding
> > Documentation should be in the patch adding the bindings. Also
> > make sure the devicetree parsing is outside of the path for platform
> > based probing.
> >
> > With this particular binding I'm unsure it should exist anyway since
> > it's configuration rather than hardware description. The devicetree
> > normally is for hardware description only.
> >
> 
> What's your opinion?
> Using module parameter, device-tree to config it or the other method?

Why do you want to make it configurable anyway? So far no other driver
seems to need this. My suggestion is to make it unconfigurable.

For adding properties like this to the devicetree remember that they
should be OS agnostic. napi is a implementation detail relevant only
for Linux. And even Linux may decide to drop napi support in favour for
something better in the future.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
