From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] smsc911x: add flag SMSC911X_USE_INTERPHY
Date: Tue, 24 Mar 2009 02:18:26 -0700 (PDT)
Message-ID: <20090324.021826.102378372.davem@davemloft.net>
References: <4e090d470903232347g2b6e91a7o385af2e66f05a936@mail.gmail.com>
	<20090324075105.GE25436@pengutronix.de>
	<4e090d470903240136y1b553b10gda626b3a9bb661f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, kernel@pengutronix.de
To: linuxzsc@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755569AbZCXJSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 05:18:39 -0400
In-Reply-To: <4e090d470903240136y1b553b10gda626b3a9bb661f5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Zhao <linuxzsc@gmail.com>
Date: Tue, 24 Mar 2009 16:36:08 +0800

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
> And I don't know why the smsc911x patch commited on Feb 1 on
> linux-next still not be merged to mainline?

Because it was not a critical regression fix, so it goes
to net-next-2.6 until the merge window opens up.
