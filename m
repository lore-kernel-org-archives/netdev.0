From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 20/20] i40e: don't allow i40e_vsi_(add|kill)_vlan to
 operate when VID<1
Date: Wed, 07 Dec 2016 13:53:14 -0800
Message-ID: <1481147594.2404.22.camel@intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
         <20161207073354.88568-21-jeffrey.t.kirsher@intel.com>
         <8f82cd1d-0118-7b37-1a05-fa7b77d4e75c@cogentembedded.com>
         <02874ECE860811409154E81DA85FBB5857CD9C6D@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-ZpVDpPdVQKF2RSCjmvnE"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "guru.anbalagane@oracle.com" <guru.anbalagane@oracle.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54804 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933291AbcLGVxR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:17 -0500
In-Reply-To: <02874ECE860811409154E81DA85FBB5857CD9C6D@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZpVDpPdVQKF2RSCjmvnE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-12-07 at 13:50 -0800, Keller, Jacob E wrote:
> > -----Original Message-----
> > From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> > Sent: Wednesday, December 07, 2016 2:11 AM
> > To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; davem@davemloft.n
> > et
> > Cc: Keller, Jacob E <jacob.e.keller@intel.com>; netdev@vger.kernel.org;
> > nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com;
> > guru.anbalagane@oracle.com
> > Subject: Re: [net-next 20/20] i40e: don't allow
> > i40e_vsi_(add|kill)_vlan to operate
> > when VID<1
> >=20
> > Hello!
> > > +=C2=A0=C2=A0=C2=A0if (!(vid > 0) || vsi->info.pvid)
> >=20
> > =C2=A0=C2=A0=C2=A0=C2=A0 Why not just '!vid'?
>=20
> Left over artifact of this previously being a signed value. We can fix
> this.
>=20
> Thanks,
> Jake
>=20
> > > -void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
> > > +void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, u16 vid)
> > > =C2=A0 {
> > > +=C2=A0=C2=A0=C2=A0if (!(vid > 0) || vsi->info.pvid)
> >=20
> > =C2=A0=C2=A0=C2=A0=C2=A0 Likewise.
>=20
> Same here. Can get this fixed.

While you are fixing this up and sending me a new version of this patch, I
will just drop this from the series and re-send.
--=-ZpVDpPdVQKF2RSCjmvnE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYSITLAAoJEOVv75VaS+3OeWEP/1MyavnRT38nRgbU3aFN5fWf
UnHycDvNiOVOnMiAV8tAdxuJjZybeeW8TDJms8J/nYl/2Dn+4GPRjRNUcUNTl9z8
8lvlJ6c6DDoUH4fgF5jgUvd3XKiSElz+C1FyCIgREQW5doF0Kaj4ZKC4g9lBqRCz
LExXvc+dLmqy0DKEYw4OSEBKsTGPkMYvwlamxZMihTMofgh+W7i65NYr+Y3zVm8q
MhBUBn4T00Mc5NWGY0tn0PAcc7LPLexLoWFLv2VwXO/ZEIfEfuuJRxGe5zYjBUjn
XZz7KGw4YKn4ZZfvN11MJbvfjeGjzzT7b0dhywVaPrvevk7N5INDbiePdIbT9XKq
S1HbzSXmZjBCXl/QNKQeLTe1+ZF9IpDfrUvnDwgIfz8lA6DBOioD9DHE35W9sxe1
Uox54N2Hy8dKpIJJelb4U6wXEBtuTAUjxaFc9Ni0vsaGwi0XVFL1ZtG/9TO4SZHZ
Q5j1c4zrAycWKXVtN9hapYYXj9bqDV45wKphfVN2sjL203XZ5G00RqALYUMJzman
JWEcGUtvuUQovHggDf2IIX58kTIoJKEmZZZn/oKsSXQdRBHCJTd1hgVfAUy85ETr
7yXtm4HoquncJ3k9sG3NGoTfEgI/3TOhlXEIgDv11zJ3zkntfBZPVh1XIIGJrQ0B
EWjy/7/5M4zsaDVK+ixs
=sqm0
-----END PGP SIGNATURE-----

--=-ZpVDpPdVQKF2RSCjmvnE--
