From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Wed, 05 Nov 2014 11:36:44 -0800
Message-ID: <1415216204.2176.1.camel@jtkirshe-mobl.jf.intel.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
	 <1415138202-1197-4-git-send-email-joestringer@nicira.com>
	 <1415190872.2420.55.camel@jtkirshe-mobl>
	 <CAJ3xEMjaQ54yEUQGL-8VHoPm=4G5bhPaGBa55jypzfKviR4KyQ@mail.gmail.com>
	 <1415191627.2420.61.camel@jtkirshe-mobl>
	 <CANr6G5xBehKGVozOAM=m8CXY7Q8_kPu-s5zgwho4=npv=bQsrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hPyQsvcWixy49SHg8+pU"
Cc: "linux.nics" <linux.nics@intel.com>,
	"shahed.shaikh" <shahed.shaikh@qlogic.com>,
	"sathya.perla" <sathya.perla@emulex.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Vadai <amirv@mellanox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	dept-gelinuxnicdev <Dept-GELinuxNICDev@qlogic.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, Amir@isotope.jf.intel.com
To: Joe Stringer <joestringer@nicira.com>,
	Matthew Vick <matthew.vick@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANr6G5xBehKGVozOAM=m8CXY7Q8_kPu-s5zgwho4=npv=bQsrg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-hPyQsvcWixy49SHg8+pU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-11-05 at 10:26 -0800, Joe Stringer wrote:
> On 5 November 2014 04:47, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrot=
e:
> >
> > On Wed, 2014-11-05 at 14:44 +0200, Or Gerlitz wrote:
> > > On Wed, Nov 5, 2014 at 2:34 PM, Jeff Kirsher
> > > <jeffrey.t.kirsher@intel.com> wrote:
> > > > On Tue, 2014-11-04 at 13:56 -0800, Joe Stringer wrote:
> > > >> ndo_gso_check() was recently introduced to allow NICs to report th=
e
> > > >> offloading support that they have on a per-skb basis. Add an
> > > >> implementation for this driver which checks for something that loo=
ks
> > > >> like VXLAN.
> > > >>
> > > >> Implementation shamelessly stolen from Tom Herbert:
> > > >> http://thread.gmane.org/gmane.linux.network/332428/focus=3D333111
> > > >>
> > > >> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> > > >> ---
> > > >> Should this driver report support for GSO on packets with tunnel
> > > >> headers
> > > >> up to 64B like the i40e driver does?
> > > >> ---
> > > >>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   12 ++++++++++=
++
> > > >>  1 file changed, 12 insertions(+)
> > > >
> > > > Thanks Joe, I will add your patch to my queue.
> > >
> > > Hi Jeff, please see my comment on patch 0/5, we're essentially
> > > replicating the same helper four different times (fm10k, mlx4, benet,
> > > qlgc) - I don't see the point in doing so. I asked Joe to come up wit=
h
> > > one generic helper and then to pick it up by the four drivers, makes
> > > sense?
> >
> > Yeah, I just saw your reply Or.  Ok, I will await an update to Joe's
> > series, thanks!
>=20
> Thanks Or/Jeff.
>=20
> There is also the question in the commit message above, perhaps fm10k
> support is a bit different - wasn't sure who to ask regarding that.

Matthew Vick is the fm10k maintainer now and can answer any fm10k
questions you may have.

--=-hPyQsvcWixy49SHg8+pU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUWnxMAAoJEOVv75VaS+3O8vQQAJ5wDMu5S5ama65ML97NbXD/
AMPpBuCQ6PtY5hXSbTmk15bHl8B0HkmgStTbl7Re9SgOcnO6wRHOyHQb42w1lFZU
AO1UCDhImQYkfEWaBad0irS369U7AKMPqhNiJl1WGPyCFjoIJq8FfeeQ3B+eGALW
TSAqHpX//0ShyeWmp2EHBJoIenVASV0eO6spzXee5tn2IZpq/k4NOTsTfriMVjGz
pRKT2NyXYoUx4VA+krHDv4veKitjybdtzkpyrIYUYAU2H2hIStmJzbUSk1FxBxiV
XjoebQiFpPwwcvnHUcZiNiOkosbw+8NSGC+sja6N5ogZIUhW4DEBDofEjLHCtrUU
FPg9lg4csKBJPwG/s4m4pRYZQ/yJsbIdXW3IQ69bGG7j234/YXeD3PrwPsK9fqNe
9N/fZ29GC+aDqHGp+IWxvqwgEozyGuK7H7ggd6Uszf2KjyEJBIrdZOUG6UQ7rQPZ
KnYFhXlUsPZd94xrCn1KlQlj6VAtyV4qpl4PeHNpqhduY+7Q8JiYuOzIc6huvktJ
oQBtE9TFa4YfnJaT6/RqWK4NJw1MmU72uclGIS8ssmPHh++U2P5/v6KAoPDcnjfP
fzmB+GfeCLgjVV79JLfpnBUEjovwArUbOdaiJYxden8DJs8NECk3jtqRwqgkCciR
pt5sF0B67NDYTDucFOh1
=rA40
-----END PGP SIGNATURE-----

--=-hPyQsvcWixy49SHg8+pU--
