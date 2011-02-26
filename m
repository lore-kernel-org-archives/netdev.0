From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: TX VLAN acceleration on bridges broken in 2.6.37?
Date: Fri, 25 Feb 2011 17:22:15 -0800
Message-ID: <1298683335.2643.165.camel@jtkirshe-MOBL1>
References: <20110221232902.GA3440@x61s.reliablesolutions.de>
	 <AANLkTinoJqWA6ffnUx2KW_83srNbo+k6r24hnNpPTGvW@mail.gmail.com>
	 <20110226001908.GA10777@x61s.reliablesolutions.de>
	 <AANLkTikVvjsaG94-gtauvTLjH_RW5fmva8+N7Lk-ryQ0@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VwjQZngdhntMAAZvhx/w"
Cc: Jan Niehusmann <jan@gondor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: Jesse Gross <jesse@nicira.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikVvjsaG94-gtauvTLjH_RW5fmva8+N7Lk-ryQ0@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VwjQZngdhntMAAZvhx/w
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-02-25 at 17:16 -0800, Jesse Gross wrote:
> On Fri, Feb 25, 2011 at 4:19 PM, Jan Niehusmann <jan@gondor.com> wrote:
> > On Fri, Feb 25, 2011 at 02:53:21PM -0800, Jesse Gross wrote:
> >> is specific to the e1000e driver.  I know that some other Intel NICs
> >> require vlan stripping on receive to be enabled for vlan insertion on
> >> transmit to work.  Since this driver has not been converted over to
> >> use the new vlan model yet, it only enables these things if a vlan is
> >> directly configured on it.  To confirm this can you try a few things:
> >
> > My observations confirm your theory:
>=20
> OK, thanks for confirming.  The right solution is convert the driver
> over to the new vlan model.  I don't know how soon I might get to
> this, maybe it's something that the Intel guys can take a look at?

I have made sure that Bruce is aware of the issue.

We will see what we can do to get some patches created and under
testing.

>=20
> > - indeed, -e is necessary to show the vlan tags. So my prior observatio=
n
> >  regarding tag visibility in tcpdump was wrong. The packets are still
> >  have a vlan tag in the non-working case.
> >
> >  (What actually is affected by the txvlan flag is the ability to filter
> >  for vlan tags with tcpdump.  so 'tcpdump -e -i eth0' shows the packets=
,
> >  'tcpdump -e -i eth0 vlan' only shows them with txvlan off. However,
> >  filtering for the vlan tag also doesn't work with the vlan interface
> >  on eth0.1, while the tagging actually works, as verified above.)
>=20
> Good to know, though that's a separate issue.



--=-VwjQZngdhntMAAZvhx/w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNaFXHAAoJECTsCADr/EWUOEkIAIS+RHFbLCFJ80V5wQoW6jXs
h8S8Dx2jsXr83mtY1ZQURubtk6tkyIoVmdRHnTqNFhifqvzpPvuXzlOB3w2oSu3q
YVAD+KRu49n4tO0+XmIYmSVmVRVdntTeP6BnwRBvcA0vswE6vvqeX7bW+0xJ8ODU
doh7+qwi11ZoE+D88VuvUcQlZqzATEKck/+XOtQ73uT0LOWBz9YiNAUUIy9dqZ04
MTQKCpO1vBrBLB9IUC7VfNOVdsm3RHfhnTz9FZEIE96WsjLsoIME5Ej1GRG/zDU0
9ENE6Jli/zf2yl+L1nBuPqC/vFMF3kqE6s9qz80aRj/rncEuGGaeBgnxI8IOpeo=
=9bqc
-----END PGP SIGNATURE-----

--=-VwjQZngdhntMAAZvhx/w--
