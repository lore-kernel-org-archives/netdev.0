From: David Miller <davem@davemloft.net>
Subject: Re: Validation of DMA params breaks e100 driver (2.6.28-rc2)
Date: Thu, 13 Nov 2008 18:42:25 -0800 (PST)
Message-ID: <20081113.184225.113857300.davem@davemloft.net>
References: <4909E08F.9040306@users.sourceforge.net>
	<20081031210131.GA18015@flint.arm.linux.org.uk>
	<Pine.WNT.4.63.0811131718390.984@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux@arm.linux.org.uk, grfstrm@users.sourceforge.net,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58089
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751155AbYKNCm0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 21:42:26 -0500
In-Reply-To: <Pine.WNT.4.63.0811131718390.984@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 13 Nov 2008 17:21:50 -0800 (Pacific Standard Time)

> On Fri, 31 Oct 2008, Russell King - ARM Linux wrote:
>=20
> > On Thu, Oct 30, 2008 at 05:27:59PM +0100, Anders Grafstr=F6m wrote:
> > > The e100 driver triggers BUG_ON(buf->direction !=3D dir)
> > > by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
> > > and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).
> > >=20
> > > I'm guessing it's allowed to do that and that something like
> > > the patch below is called for?
> >=20
> > No, it is not allowed to do that - that's why it's called "BUG_ON".
> > Changing the DMA direction, especially with dmabounce will result
> > in unexpected behaviour.
>=20
> okay, how about this patch...  only compile tested as I couldn't get=20
> net-next-2.6 to boot on my test machine.  I'll get some testing done =
on=20
> this, but in the meantime....
>=20
> e100: fix dma error in direction for mapping
>=20
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

=46WIW this looks good to me.

Acked-by: David S. Miller <davem@davemloft.net>
