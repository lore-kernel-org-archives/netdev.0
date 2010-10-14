From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next] drivers/net Documentation/networking:
 Create directory intel_wired_lan
Date: Wed, 13 Oct 2010 21:57:35 -0700
Message-ID: <1287032255.4113.14.camel@jtkirshe-MOBL1>
References: <1286743352.11039.165.camel@Joe-Laptop>
	 <AANLkTikVKufQRuMGd=cdig7ff4k2aw9Q1FWwMz3pgon-@mail.gmail.com>
	 <1286841648.26045.17.camel@Joe-Laptop>
	 <1287008906.1117.428.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-O0ZyhiWHqm51Wn4L2CMV"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
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
In-Reply-To: <1287008906.1117.428.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-O0ZyhiWHqm51Wn4L2CMV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-10-13 at 15:28 -0700, Joe Perches wrote:
> On Mon, 2010-10-11 at 17:00 -0700, Joe Perches wrote:
> > On Mon, 2010-10-11 at 16:52 -0700, Jeff Kirsher wrote:
> > > On Sun, Oct 10, 2010 at 13:42, Joe Perches <joe@perches.com> wrote:
> > > > Perhaps it's better to move drivers from the very populated
> > > > drivers/net directory into vendor specific directories similar
> > > > to the Atheros approach used for drivers/net/wireless/ath/
> > > NAK
> > > First, I think we need to keep the documentation in /Documentation/ne=
tworking.
> > > Second, the changes are extensive and would create a lot of regressio=
n testing.
> > I don't see any actual changes here other than layout.
> > What kind of regression testing do you think necessary?
>=20
> Jeff?
>=20

Sorry I am not ignoring you, I was taking a closer look at your patch.

> What regression testing would actually be done?
>=20

The Makefile and Kconfig needs more work.  I applied your patch and none
of the Intel Wired drivers build.

The statement that there would be a lot of regression testing was in
reference to your response to Stephen that it would "allow consolidation
of common code".  Sorry for being vague about the regression testing.

In general, I do like the idea of moving all the Intel wired LAN drivers
into their own directory, like was Atheros has done in Wireless.

I am working on providing an updated RFC patch to resolve the
Makefile/Kconfig issues I found and few other minor issues I have
found.=20

> Any new objects are trivially validated against existing
> objects.
>=20
> > > We have been looking at solutions like this for future
> > > drivers/hardware and is on the list of items we are currently working
> > > on, but feel it should not be made retroactively due to the regressio=
n
> > > testing and massive changes that would need to be made.
> >=20
> > Might as well start somewhere.




--=-O0ZyhiWHqm51Wn4L2CMV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAABAgAGBQJMto20AAoJECTsCADr/EWURS8H/0sYvy726w1aNz8l3wWob9Og
a7boBWtwfmrRzS/XbwaSFBOgxrdBOyhfLk1/bLx93jYctQDemqucJOQ/nGCRefJZ
jbfmXkVhQDkdvF+daByUOh5iLHpkB4AgQkJmd8Ss4dAyiOFQ30284o1SanjIJ7VZ
PiL9Jc6e3uSPamIHpP6iEneAJZki7pTngkE4fPMtKeogAfYXzyiYMY/OA3zElJhR
+tf9AxhDM0kw2fhgXrgpDVnfFhuy+ZPI2oLRLg4mm4Fof8Mbqp2jnQrkrUiEwbcL
qCVyfFpejLR3SRdDUzvvqZMSV9PnNgw6TzYYKRzJjB44jVw/Uc2TIszOb4hJFSA=
=IDYD
-----END PGP SIGNATURE-----

--=-O0ZyhiWHqm51Wn4L2CMV--
