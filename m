From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [stable-2.6.32 PATCH] ixgbe: backport bug fix for tx
 panic
Date: Fri, 2 Jul 2010 19:28:09 -0700
Message-ID: <20100703022809.GA24141@kroah.com>
References: <20100511004655.30590.74584.stgit@localhost.localdomain>
 <AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
 <alpine.WNT.2.00.1005250926320.2708@jbrandeb-desk1.amr.corp.intel.com>
 <20100525201837.GA13821@kroah.com>
 <AANLkTimr7-8TIjuCjIbqrJSVH4VI-Pjp8plpjTubuTfE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@kernel.org" <stable@kernel.org>,
	Brandon <brandon@ifup.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimr7-8TIjuCjIbqrJSVH4VI-Pjp8plpjTubuTfE@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 02, 2010 at 02:37:13PM -0700, Jeff Kirsher wrote:
> On Tue, May 25, 2010 at 13:18, Greg KH <greg@kroah.com> wrote:
> > On Tue, May 25, 2010 at 09:27:25AM -0700, Brandeburg, Jesse wrote:
> >>
> >>
> >> On Tue, 25 May 2010, Jeff Kirsher wrote:
> >>
> >> > On Mon, May 10, 2010 at 17:46, Jeff Kirsher <jeffrey.t.kirsher@i=
ntel.com> wrote:
> >> > > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >> > >
> >> > > backporting this commit:
> >> > >
> >> > > commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f
> >> > > Author: Krishna Kumar <krkumar2@in.ibm.com>
> >> > > Date: =A0 Wed Feb 3 13:13:10 2010 +0000
> >> > >
> >> > > =A0 =A0ixgbe: Fix return of invalid txq
> >> > >
> >> > > =A0 =A0a developer had complained of getting lots of warnings:
> >> > >
> >> > > =A0 =A0"eth16 selects TX queue 98, but real number of TX queue=
s is 64"
> >> > >
> >> > > =A0 =A0http://www.mail-archive.com/e1000-devel@lists.sourcefor=
ge.net/msg02200.html
> >> > >
> >> > > =A0 =A0As there was no follow up on that bug, I am submitting =
this
> >> > > =A0 =A0patch assuming that the other return points will not re=
turn
> >> > > =A0 =A0invalid txq's, and also that this fixes the bug (not te=
sted).
> >> > >
> >> > > =A0 =A0Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> >> > > =A0 =A0Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel=
=2Ecom>
> >> > > =A0 =A0Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@=
intel.com>
> >> > > =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m>
> >> > > =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
> >> > >
> >> > > CC: Brandon <brandon@ifup.org>
> >> > > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >> > > ---
> >> > >
> >> > > =A0drivers/net/ixgbe/ixgbe_main.c | =A0 =A08 ++++++--
> >> > > =A01 files changed, 6 insertions(+), 2 deletions(-)
> >> > >
> >> >
> >> > Greg - status? =A0Did you queue this patch for the stable releas=
e and I missed it?
> >>
> >> Maybe we didn't say (and we should have) that this fixes a panic o=
n
> >> machines with > 64 cores. =A0Please apply to -stable 32.
> >
> > I'll get to it for the next release after this one, if that's ok.
> >
> > thanks,
> >
> > greg k-h
> > --
>=20
> I did not see this patch in the list of patches for the next release
> of the stable kernel.  Just want to make sure this patch makes it thi=
s
> time... :)

Ick, I missed it, let me go queue it up right now, sorry about that.

greg k-h
