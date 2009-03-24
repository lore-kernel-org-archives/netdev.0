From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 3/3] smsc911x: add flag SMSC911X_USE_INTERPHY
Date: Tue, 24 Mar 2009 09:52:48 +0100
Message-ID: <20090324085248.GH25436@pengutronix.de>
References: <4e090d470903232347g2b6e91a7o385af2e66f05a936@mail.gmail.com> <20090324075105.GE25436@pengutronix.de> <4e090d470903240136y1b553b10gda626b3a9bb661f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, kernel@pengutronix.de
To: Richard Zhao <linuxzsc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55643 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbZCXIxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 04:53:13 -0400
Content-Disposition: inline
In-Reply-To: <4e090d470903240136y1b553b10gda626b3a9bb661f5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 04:36:08PM +0800, Richard Zhao wrote:
> On Tue, Mar 24, 2009 at 3:51 PM, Sascha Hauer <s.hauer@pengutronix.de> wrote:
> > Hi Richard,
> >
> > On Tue, Mar 24, 2009 at 02:47:25PM +0800, Richard Zhao wrote:
> >> mx31pdk board don't have external PHY, but it wrongly pull up MDIO.
> >> So, add flag SMSC911X_USE_INTERPHY to force using internal PHY.
> >
> > This patch is outdated. Linux-next already contains a
> > SMSC911X_FORCE_INTERNAL_PHY for exactly this reason.
> >
> > Sascha
> >
> Hi Sascha,
> 
> Sorry I didn't check linux-next. Do I need always to create mxc
> patches based on linux-nex?

No, but you should keep an eye on it to check for changes.

> And I don't know why the smsc911x patch commited on Feb 1 on
> linux-next still not be merged to mainline?

Have a look at Documentation/development-process in the Kernel sources.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
