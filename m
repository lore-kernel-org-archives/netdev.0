From: David Gibson <dgibson@redhat.com>
Subject: Re: rtnetlink problems with Cisco enic and VFs
Date: Wed, 23 Apr 2014 09:24:58 +1000
Message-ID: <20140423092458.d9b5ee99d389e30e87b86376@redhat.com>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
	<6CE81A2095B0024BBC77007BD04E553823E85BC2@xmb-aln-x02.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__23_Apr_2014_09_24_58_+1000_DeM_wnSDj3n4psv3"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>
To: "Christian Benvenuti (benve)" <benve@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbaDVXZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 19:25:08 -0400
In-Reply-To: <6CE81A2095B0024BBC77007BD04E553823E85BC2@xmb-aln-x02.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__23_Apr_2014_09_24_58_+1000_DeM_wnSDj3n4psv3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Apr 2014 19:14:04 +0000
"Christian Benvenuti (benve)" <benve@cisco.com> wrote:

> David,
>=20
> > -----Original Message-----
> > From: David Gibson [mailto:dgibson@redhat.com]
> > Sent: Monday, April 21, 2014 9:14 PM
> > To: netdev@vger.kernel.org
> > Cc: Christian Benvenuti (benve); Sujith Sankar (ssujith); Govindarajulu
> > Varadarajan; Neel Patel (neepatel); Nishank Trivedi
> > Subject: RFC: rtnetlink problems with Cisco enic and VFs
> >=20
> > I believe I've found a problem with netlink handling which can be trigg=
ered
> > on Cisco enic devices with a large number (30-40) of virtual functions.=
  I
> > believe this is the cause of a real customer problem we've seen.
> >=20
> >  * When requesting a list of interfaces with RTM_GETLINK, enic devices
> >    (and currently, _only_ enic devices) report IFLA_VF_PORTS
> >    information
>=20
> Is the fact that Enic is the only driver implementing ndo_get_vf_port [1]
> the root cause of the problem and the reason why this happens only with E=
nic?

Yes, or at least it's one of the factors.

>=20
> /Chris
>=20
> [1]
> This is what makes rtnl_port_size to account for vf_port_size*dev_num_vf(=
...)
> and rtnl_port_fill to add IFLA_VF_PORTS.

--=20
David Gibson <dgibson@redhat.com>

--Signature=_Wed__23_Apr_2014_09_24_58_+1000_DeM_wnSDj3n4psv3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTVvpKAAoJEGw4ysog2bOSMAUP/29eohx3ZNUQmGZ2Kl7f4RGO
A3Sf0VAYEDqUMXmz8PYu37WB/XaG36rwvb3mdPyMuke9vhPuWigFAOJTDKAcVVS4
YlD9xQoFv4RHQHKFuyepU7NDYb63L19wO7bPFFHGOzefs3nucj9rLQKbtdYVckgl
/Ix1ebl9molpYzWnx+DOjZLhDBYNksvunrG1YYGc3uPMCtjFZ1dvPe3Q6w7HHM9E
S6ssA6EPkFF+DAjQcv1o+kLbtw2pgQfWaFTgeYuQwZyDwGaMXwwOgyAOvGAYSNrl
X3awpvWkW7oDCuljynN2Fz3n5D27XD0OXm3WCyczdY/Eah/SROtri0r1hOyUoqRG
WINe4tvVS1JOfvstSbyT+SV0ALdAyXzo9xIyxZ91oAt25Ja80BBz/wPkaMu1Wq6H
nuZFJBODR2aaPUacuA4V3iDPdw6qfgLbFYGMPjssvFt1grcn7i4kZeFRzBf9r/yn
+zcKAfxTavauYadyLLUcxd/d8295cgGIRQ4nD6wy0eDsZCuETPH94YpSPsIaSU6E
sU6jyFIJ932lMKXCYYQm42fqolaX+5L6Mwh/g7th6kBldElYGWPXegvOz9BSaCKA
EkTiP1/gVKS5Zd53ErZYJ5wmC+oKEe8DZ+7Ch6ji0ah8dPKMTZmxQHeGuJn361QM
vtAJaotGC4R2OvDfD8GL
=VrpK
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Apr_2014_09_24_58_+1000_DeM_wnSDj3n4psv3--
