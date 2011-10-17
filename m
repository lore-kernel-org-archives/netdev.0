From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 2/6] igb: Check if subordinate VFs are assigned to
 virtual machines
Date: Mon, 17 Oct 2011 04:54:06 -0700
Message-ID: <1318852447.2960.50.camel@jtkirshe-mobl>
References: <1318851161-30163-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1318851161-30163-3-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5Lf0YwENXWrZv10D4UMA"
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Christian Benvenuti <benve@cisco.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Jon Mason <jdmason@kudzu.us>,
	James Smart <james.smart@emulex.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47198 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191Ab1JQLyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 07:54:07 -0400
In-Reply-To: <1318851161-30163-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5Lf0YwENXWrZv10D4UMA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-10-17 at 04:32 -0700, Kirsher, Jeffrey T wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>=20
> Kvm and the Xen pci-back driver will set a flag in the virtual
> function
> pci device dev_flags when the VF is assigned to a guest VM.  Before
> destroying subordinate VFs check to see if the flag is set and if so
> skip the call to pci_disable_sriov() to avoid system crashes.
>=20
> Copy the maintainer for the Xen pci-back driver.  Also CC'ing
> maintainers of all drivers found to call pci_disable_sriov().
>=20
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Christian Benvenuti <benve@cisco.com>
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Dimitris Michailidis <dm@chelsio.com>
> Cc: Jon Mason <jdmason@kudzu.us>
> Cc: James Smart <james.smart@emulex.com>
>=20
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>=20

Dave- please do not pull this patch (or the series).  There is an issue
with this patch.

--=-5Lf0YwENXWrZv10D4UMA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOnBdeAAoJEOVv75VaS+3OqxwP/A77hvbCnzVkYD9/i8Elu0Pq
kVKShvpAm/6ecAq8sfBdduwEpVVjlA4Y2HF+1egXmnb6LVCFtnjRWD6+bbtKGl/X
AD2B+vgM/fXP195UTwAOfjPVOt5LLYzJ5N+Yfg1ZQNkQX7GQQGMUXxlGXuN3uI7S
YbHd94mkcHkEnRaEPnUBHN+WjwpOSM+ub70TPv2Ri2IxdYjoSVxHz+z9TKj1hoKy
ygqROdkjsfpnaeHnkL6v5mIyl9Ag6d41C9xcEKHZ/Q3geAHNb7Qyevhd/v1y4p5s
4vdJZ9JCpnfK+iQPm2FO10T+FC2SgyYwEH8Vwv/7cGiwOtjmjnEdsdh0szShizQz
CNt3vpQFxwTwQMK/0ap38QqWbzn3NUPumEMIU5oukeMFhVutTiAHY6RPuCIcaPIh
a1Fjs+MYnUMcSfAH7FH35u63nPpkTaxEw1VkOjecaIS8f5EDvJW5uJkHr9REu0pG
9cbS/EfIvB+Pg9KMBX0jRQoAyBgCDDfRfUK59vUuTCsC7wGTPw8MbLJat3q6tG+8
rwKdstmoth6JvJxX5SsZZs8zkDExsTSynSFF7BAkM/aQJ7Z4qdmDtmU1fYWq5dwG
1u5ErL7vjwK79wsnL0mrPaII/nRbzOej1om8tPm53ifxdsA3qF+gHhSsy4eB1F67
a5GuwvgEegy19YbT7qua
=1DCj
-----END PGP SIGNATURE-----

--=-5Lf0YwENXWrZv10D4UMA--
