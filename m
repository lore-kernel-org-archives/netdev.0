From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next] drivers/net Documentation/networking:
 Create directory intel_wired_lan
Date: Thu, 14 Oct 2010 15:20:38 -0700
Message-ID: <1287094838.8235.32.camel@jtkirshe-MOBL1>
References: <1286743352.11039.165.camel@Joe-Laptop>
	 <AANLkTikVKufQRuMGd=cdig7ff4k2aw9Q1FWwMz3pgon-@mail.gmail.com>
	 <1286841648.26045.17.camel@Joe-Laptop>
	 <1287008906.1117.428.camel@Joe-Laptop>
	 <1287032255.4113.14.camel@jtkirshe-MOBL1>
	 <1287035857.1117.528.camel@Joe-Laptop>
	 <1287048849.3319.20.camel@jtkirshe-MOBL1>
	 <1287084643.1117.602.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-B22xvyGqAD1NvT+4/x4f"
Cc: Michal Marek <mmarek@suse.cz>, Sam Ravnborg <sam@ravnborg.org>,
	"linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1287084643.1117.602.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-B22xvyGqAD1NvT+4/x4f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-10-14 at 12:30 -0700, Joe Perches wrote:
> On Thu, 2010-10-14 at 02:34 -0700, Jeff Kirsher wrote:
> > On Wed, 2010-10-13 at 22:57 -0700, Joe Perches wrote:
> > > On Wed, 2010-10-13 at 21:57 -0700, Jeff Kirsher wrote:
> > > > On Wed, 2010-10-13 at 15:28 -0700, Joe Perches wrote:
> > > > Sorry I am not ignoring you, I was taking a closer look at your pat=
ch.
> > > > > What regression testing would actually be done?
> > > > The Makefile and Kconfig needs more work.  I applied your patch and=
 none
> > > > of the Intel Wired drivers build.
> > > Care to describe the Makefile/Kconfig issues you have seen?
> > > I built it allyesconfig, defconfig, allmodconfig and allnoconfig.
> > Yeah, I found all of those built without errors, but if you build the
> > Intel Wired LAN drivers as modules, you will not find the *.ko files
> > after the build.  The Kconfig files look fine, the problem was with the
> > Makefiles.  Instead of creating a drivers/net/intel_wired_lan/Makefile,
> > I simply changed the path in drivers/net/Makefile to the updated path
> > and that resolved the issue.
>=20
> (adding a few cc's and a link for history)
>=20
> http://lkml.org/lkml/2010/10/10/207
>=20
> That's the way I had done it originally as well, but I found
> you couldn't build the directory with:
>=20
> 	make drivers/net/intel_wired_lan/
>=20
> so I created a Makefile in the new directory below with
> the elements necessary.
>=20
> Perhaps there's some missing functionality in the build system
> when the Kconfig file resides in a higher directory and the
> directory being built doesn't have a Kconfig file?
>=20
> I think it'd wrong to duplicate the makefile components in
> 2 places to allow "make subdir/" and I wonder if there's a
> good solution for this.
>=20
> > As far as the sub-directory name "intel_wired_lan", what about "intel"
> > or "intel_wired"?  Just a thought...
>=20
> Using "intel" seemed too sweeping because of the wireless drivers.
> I think intel_wired_lan isn't overly long, but your choice...
>=20
> Should the new (OKI?/intel) pch_gbe directory be moved as well?
> It's using a PCI_VENDOR_ID_INTEL.
>=20
>=20

No, the pch_gbe is not our driver.

--=-B22xvyGqAD1NvT+4/x4f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAABAgAGBQJMt4I1AAoJECTsCADr/EWU2oYIAI/6FT0RFq/UrjAypW2l5WjU
cOyHiPHau7NTorQ8OFU1Ac1vjNbheLxK8CDa8jbBn9oNfssu1pq6tmv3cFmtK0qr
Dh+8IWYwBWIYhV0KOEBIlb60sI3ef3kgTR/tX6iVGBuSD4udOgMYhkqGHl3p869a
IRQbRpHa1M8LADUYkd4c8xZXmL8YLPZGpnyLlndgqEwyLytBnxp89mZeDu13lbBE
TzCXI9f4d6g+b9+qfZ8G1wM8wFeHPKBd/cqHOl/1ExsxYYNugb8uOdKV0rhU3uwX
bp/HKtLwNi7EBBwqejS44fhz1p6iG4IpaIkvZpMQlSUNcVMMizp7/mv8v2pg310=
=wjiw
-----END PGP SIGNATURE-----

--=-B22xvyGqAD1NvT+4/x4f--
