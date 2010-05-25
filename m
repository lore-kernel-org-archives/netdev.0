From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [stable-2.6.32 PATCH] ixgbe: backport bug fix for tx panic
Date: Tue, 25 May 2010 09:27:25 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1005250926320.2708@jbrandeb-desk1.amr.corp.intel.com>
References: <20100511004655.30590.74584.stgit@localhost.localdomain> <AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "stable@kernel.org" <stable@kernel.org>,
	"greg@kroah.com" <greg@kroah.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Brandon <brandon@ifup.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 25 May 2010, Jeff Kirsher wrote:

> On Mon, May 10, 2010 at 17:46, Jeff Kirsher <jeffrey.t.kirsher@intel.=
com> wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >
> > backporting this commit:
> >
> > commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f
> > Author: Krishna Kumar <krkumar2@in.ibm.com>
> > Date: =C2=A0 Wed Feb 3 13:13:10 2010 +0000
> >
> > =C2=A0 =C2=A0ixgbe: Fix return of invalid txq
> >
> > =C2=A0 =C2=A0a developer had complained of getting lots of warnings=
:
> >
> > =C2=A0 =C2=A0"eth16 selects TX queue 98, but real number of TX queu=
es is 64"
> >
> > =C2=A0 =C2=A0http://www.mail-archive.com/e1000-devel@lists.sourcefo=
rge.net/msg02200.html
> >
> > =C2=A0 =C2=A0As there was no follow up on that bug, I am submitting=
 this
> > =C2=A0 =C2=A0patch assuming that the other return points will not r=
eturn
> > =C2=A0 =C2=A0invalid txq's, and also that this fixes the bug (not t=
ested).
> >
> > =C2=A0 =C2=A0Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > =C2=A0 =C2=A0Signed-off-by: Jesse Brandeburg <jesse.brandeburg@inte=
l.com>
> > =C2=A0 =C2=A0Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr=
@intel.com>
> > =C2=A0 =C2=A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.c=
om>
> > =C2=A0 =C2=A0Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > CC: Brandon <brandon@ifup.org>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > ---
> >
> > =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A08 ++++++--
> > =C2=A01 files changed, 6 insertions(+), 2 deletions(-)
> >
>=20
> Greg - status?  Did you queue this patch for the stable release and I=
 missed it?

Maybe we didn't say (and we should have) that this fixes a panic on=20
machines with > 64 cores.  Please apply to -stable 32.
