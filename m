From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2] ethtool : Allow ethtool to set interface in loopback
 mode.
Date: Sat, 4 Dec 2010 20:33:48 -0500
Message-ID: <20101204203348.cf4fc883.billfink@mindspring.com>
References: <AANLkTikxHDksqrvG4uNJ8JVY5AJgcftQy2F4ihJBV=TE@mail.gmail.com>
	<1291299660.3259.5.camel@bwh-desktop>
	<AANLkTi=GygGKnuSZmWecmGejDjzLx2uaHuk+DroVfHDy@mail.gmail.com>
	<20101203160333.GA235120@jupiter.n2.diac24.net>
	<1291394014.13384.7.camel@bwh-desktop>
	<20101203164844.GB235120@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:57605 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755900Ab0LEBd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 20:33:57 -0500
In-Reply-To: <20101203164844.GB235120@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Dec 2010, David Lamparter wrote:

> On Fri, Dec 03, 2010 at 04:33:34PM +0000, Ben Hutchings wrote:
> > On Fri, 2010-12-03 at 17:03 +0100, David Lamparter wrote:
> > > On Thu, Dec 02, 2010 at 02:35:51PM -0800, Mahesh Bandewar wrote:
> > > > This patch adds -L command-line option to switch loopback mode on/off
> > > > and -l option to display current loopback mode on a specified interface.
> > > [...]
> > > > +.A1 on off
> > > > +Switches loopback mode
> > > > +.B on
> > > > +or
> > > > +.B off
> > > 
> > > What about devices that support different kinds of loopback, like MAC
> > > loopback & PHY loopback? (No idea if we have kernel support for this
> > > either...)
> > 
> > That distinction is useful for diagnostic purposes, but drivers can
> > already cover those different loopback modes in self-test.  The
> > motivation for this feature is testing data path behaviour, and Mahesh
> > has specified that loopback should be enabled as near as possible to the
> > host.
> 
> Ah, good enough. Thanks.

Perhaps in the future it could be extended, if desired,
to something like:

	loopback=0	disabled
	loopback=1	driver loopback nearest host
	loopback=2	driver loopback nearest network

Both types of loopback could be useful for different purposes.

					-Bill
