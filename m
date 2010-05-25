From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [stable-2.6.32 PATCH] ixgbe: backport bug fix for tx
 panic
Date: Tue, 25 May 2010 13:18:37 -0700
Message-ID: <20100525201837.GA13821@kroah.com>
References: <20100511004655.30590.74584.stgit@localhost.localdomain>
 <AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
 <alpine.WNT.2.00.1005250926320.2708@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@kernel.org" <stable@kernel.org>,
	Brandon <brandon@ifup.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1005250926320.2708@jbrandeb-desk1.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2010 at 09:27:25AM -0700, Brandeburg, Jesse wrote:
>=20
>=20
> On Tue, 25 May 2010, Jeff Kirsher wrote:
>=20
> > On Mon, May 10, 2010 at 17:46, Jeff Kirsher <jeffrey.t.kirsher@inte=
l.com> wrote:
> > > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > >
> > > backporting this commit:
> > >
> > > commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f
> > > Author: Krishna Kumar <krkumar2@in.ibm.com>
> > > Date: =A0 Wed Feb 3 13:13:10 2010 +0000
> > >
> > > =A0 =A0ixgbe: Fix return of invalid txq
> > >
> > > =A0 =A0a developer had complained of getting lots of warnings:
> > >
> > > =A0 =A0"eth16 selects TX queue 98, but real number of TX queues i=
s 64"
> > >
> > > =A0 =A0http://www.mail-archive.com/e1000-devel@lists.sourceforge.=
net/msg02200.html
> > >
> > > =A0 =A0As there was no follow up on that bug, I am submitting thi=
s
> > > =A0 =A0patch assuming that the other return points will not retur=
n
> > > =A0 =A0invalid txq's, and also that this fixes the bug (not teste=
d).
> > >
> > > =A0 =A0Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > > =A0 =A0Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.co=
m>
> > > =A0 =A0Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@int=
el.com>
> > > =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
> > >
> > > CC: Brandon <brandon@ifup.org>
> > > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > > ---
> > >
> > > =A0drivers/net/ixgbe/ixgbe_main.c | =A0 =A08 ++++++--
> > > =A01 files changed, 6 insertions(+), 2 deletions(-)
> > >
> >=20
> > Greg - status?  Did you queue this patch for the stable release and=
 I missed it?
>=20
> Maybe we didn't say (and we should have) that this fixes a panic on=20
> machines with > 64 cores.  Please apply to -stable 32.

I'll get to it for the next release after this one, if that's ok.

thanks,

greg k-h
