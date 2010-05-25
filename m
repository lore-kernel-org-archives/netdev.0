From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [stable-2.6.32 PATCH] ixgbe: backport bug fix for tx
 panic
Date: Tue, 25 May 2010 11:19:35 -0700
Message-ID: <20100525181935.GA11150@kroah.com>
References: <20100511004655.30590.74584.stgit@localhost.localdomain>
 <AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Brandon <brandon@ifup.org>, davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:44515 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933086Ab0EYSWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 14:22:21 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 12:15:12AM -0700, Jeff Kirsher wrote:
> On Mon, May 10, 2010 at 17:46, Jeff Kirsher <jeffrey.t.kirsher@intel.=
com> wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >
> > backporting this commit:
> >
> > commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f
> > Author: Krishna Kumar <krkumar2@in.ibm.com>
> > Date: =A0 Wed Feb 3 13:13:10 2010 +0000
> >
> > =A0 =A0ixgbe: Fix return of invalid txq
> >
> > =A0 =A0a developer had complained of getting lots of warnings:
> >
> > =A0 =A0"eth16 selects TX queue 98, but real number of TX queues is =
64"
> >
> > =A0 =A0http://www.mail-archive.com/e1000-devel@lists.sourceforge.ne=
t/msg02200.html
> >
> > =A0 =A0As there was no follow up on that bug, I am submitting this
> > =A0 =A0patch assuming that the other return points will not return
> > =A0 =A0invalid txq's, and also that this fixes the bug (not tested)=
=2E
> >
> > =A0 =A0Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > =A0 =A0Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > =A0 =A0Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel=
=2Ecom>
> > =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > CC: Brandon <brandon@ifup.org>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > ---
> >
> > =A0drivers/net/ixgbe/ixgbe_main.c | =A0 =A08 ++++++--
> > =A01 files changed, 6 insertions(+), 2 deletions(-)
> >
>=20
> Greg - status?  Did you queue this patch for the stable release and I=
 missed it?

Nope, I missed it, sorry.

I'll make sure to get it for the next .32 round.

thanks,

greg k-h
