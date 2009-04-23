From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] Add new cs89x0 driver
Date: Thu, 23 Apr 2009 09:03:19 +0200
Message-ID: <20090423070319.GN21747@pengutronix.de>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <20090422225328.GA14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:48818 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbZDWHDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 03:03:22 -0400
Content-Disposition: inline
In-Reply-To: <20090422225328.GA14729@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 12:53:28AM +0200, Lennert Buytenhek wrote:
> On Wed, Apr 22, 2009 at 09:59:30AM +0200, Sascha Hauer wrote:
> 
> > While this is a very old chip it is still in use on some embedded
> > boards.  I see myself unable to fix the in Kernel driver to bring
> > it to driver model support, so this patch adds a new driver designed
> > to replace the old one, at least for non-ISA hardware.
> 
> I had the same thought initially when I started working on mv643xx_eth,
> but I decided to try and beat the existing driver into shape anyway.  The
> mv643xx_eth driver now is not too different from how I would have written
> it had I rewritten it from scratch, and refactoring it took about a
> hundred commits and probably a bunch more effort than just rewriting it
> would have taken, but in the end I probably _saved_ myself time by being
> able to (have users) bisect problems instead of having to spend time
> trying to figure out why driver A works but B doesn't or vice versa, not
> having to chase people to switch their platforms over to the new driver,
> etc.
> 
> (I'm not saying that there's absolutely no other way for you to go than
> to do the same thing -- it's just a thought.)

I've gone that way with the fec.c driver recently, now I'm trying the
other way ;)

The problem with the cs89x0 driver is that it is an ISA driver. I think
it will be hard to find testers owning an ISA card with a cs89x0 chip.
(If you, dear reader, are one of those, please speak up)
For the embedded users it's simple. There are some Freescale i.MX Board
which I own myself or stay in contact with people who have one and some
IXP boards.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
