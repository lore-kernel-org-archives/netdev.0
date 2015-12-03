From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v5] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 03 Dec 2015 13:35:24 -0800
Message-ID: <1449178524.3224.50.camel@intel.com>
References: <20151104193956.GD14575@oracle.com>
	 <CAHp75Vcrx+Rkz2mDSG+GEUW6LdO0w6On=6UoV4fhZK27Ayf1zQ@mail.gmail.com>
	 <FC41C24E35F18A40888AACA1A36F3E418AFAEA1A@fmsmsx115.amr.corp.intel.com>
	 <20151203154823.GA23433@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dfqiBsIEDJfVdb9sfzu8"
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev <netdev@vger.kernel.org>,
	"Nelson, Shannon" <shannon.nelson@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3814 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731AbbLCVfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 16:35:44 -0500
In-Reply-To: <20151203154823.GA23433@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dfqiBsIEDJfVdb9sfzu8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-12-03 at 10:48 -0500, Sowmini Varadhan wrote:
> The patch here: http://patchwork.ozlabs.org/patch/540218/
> is marked "Awaiting Upstream", I think that means it has to first
> show up in some other repo first (which one?)?
>=20
> On addiitonal testing, we found a bug in the patch: if
> we did not find the macaddr from Open Firmwre or IDPROM (i.e.,
> defaults
> were ok) then you dont want to be doing i40e_macaddr_init again, else
> you will get a failure like this (truncated dump_stack shown
> below)
>=20
> [ 8127.050926] WARNING: CPU: 18 PID: 878 at kernel/irq/manage.c:1346
> __free_irq+0x9f/0x230()
> [ 8127.050927] Trying to free already-free IRQ 177
> =C2=A0 :
> [ 8127.051013]=C2=A0 [<ffffffffa043ddd0>]
> i40e_clear_interrupt_scheme+0xb0/0xc0 [i40e]
> [ 8127.051018]=C2=A0 [<ffffffffa044b538>] i40e_probe.part.64+0x1018/0x132=
0
> [i40e]
> =C2=A0 :
> [ 8127.051057]=C2=A0 [<ffffffffa044b862>] i40e_probe+0x22/0x30 [i40e]
>=20
> I can think of a couple of ways to fix this- one (the ugly
> way) is to ifdef the i40e_macaddr_init invocation for CONFIG_OF or
> CONFIG_SPARC
> only. Another way to solve this is to track some bit in struct
> i40e_hw that=20
> indicates that the macaddr is not the default, thus
> i40e_macaddr_init() should
> be called before register_netdev only if that bit is set. (Dont know
> if there are cache-line considerations that exist in i40e_hw that
> need to be taken into account for the second version)
>=20
> In order to send a fix out for review, what should I clone?=20
> should I just apply the patch/540218 to net-next and send the update?

I will drop your current patch in my next-queue tree (dev-queue branch)
and will await an updated patch. =C2=A0
--=-dfqiBsIEDJfVdb9sfzu8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWYLWcAAoJEOVv75VaS+3OtwIP/2cnUQUinoMfi5rwdWW8Pgqe
ftzV/D6HvL3SXOLYUiTZYryWLPWg8LbFQIwO7L/dJCqCIe9jrWzHmF56x6H5crOh
0Os+zIY/VcYzUHIth6Y9uWbmfGvYYBO0aHNK717e1fW2y/dOULvjEKFueF9d3n63
G3733iyU0v1SNw/P1IEpF9KNg+SpMyIRa9G1L4qlARjGiYCAD91dKE9020lpnYDK
GCgoDsSD6AEqttxAtZMHzLmhuFF012Bl7hUTV6yxItha93w8lY6DYmbNGkQbzO2l
14TG6ibLyhoLjMzVlUdme9TYGrkT4FmzPZgCgiR9D0V2qpg7QN12zdcc0LqKhWXw
o5VE3Gc9nx0HswEyDzC6cPRRRsgSVm7+gsApoytnGddYcDc2EFeDYm1nbct1A2LH
ulc29QhURv8lP+Dmmgud6SXWeQwnMpDUI8PAEMUGVxqkRQEJUQuBOwc0Z+5DPLaS
kv0D+Zt9KDIAgPH+uTvAudFV/9BsTlA8xmUkbJuIcKboBQc+uVvsK7s0q4JdAA3j
L5ajSNgczDiHj0Lr+mbY3HABsaAJI7603VmdoX7RF/L9Q8KoKlSaW2crbJqk0ev9
KekLbl2a+bn20FULzTKFsZIQqkXetomS8vahemumug8u3Ep0QA4SZbADJ7ht37wH
tPySLf4zQL4IrZP0DnWz
=/h0U
-----END PGP SIGNATURE-----

--=-dfqiBsIEDJfVdb9sfzu8--
