From: William Dauchy <william@gandi.net>
Subject: Re: loop on reset adapter with ixgbe
Date: Mon, 2 Dec 2013 13:42:47 +0100
Message-ID: <20131202124247.GO6428@gandi.net>
References: <20131120182524.GC16953@gandi.net>
 <F6FB0E698C9B3143BDF729DF222866466FD88724@ORSMSX110.amr.corp.intel.com>
 <20131126130410.GD2849@gandi.net>
 <F6FB0E698C9B3143BDF729DF222866466FD8A479@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eQyCKlb8USywWNtC"
Cc: William Dauchy <william@gandi.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Potenza, Leonardo" <leonardo.potenza@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:53527 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494Ab3LBMmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Dec 2013 07:42:52 -0500
Content-Disposition: inline
In-Reply-To: <F6FB0E698C9B3143BDF729DF222866466FD8A479@ORSMSX110.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eQyCKlb8USywWNtC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Skidmore,

Sorry for the late answer, I needed to wait for a physical access.

On Nov26 18:59, Skidmore, Donald C wrote:
> [root@dcsworkstation src]# ethtool -i p258p1
> driver: ixgbe
> version: 3.11.33-k
> firmware-version: 0x18eb0001
> bus-info: 0000:05:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: no
>=20
> Then use that address to find the device ID:
>=20
> [root@dcsworkstation src]# lspci -ns 0000:05:00.0
> 05:00.0 0200: 8086:10fb (rev 01)

for me it is:
03:00.0 0200: 8086:10fb (rev 01)

> As for the FW version I'm concerned that yours might not be correct from =
the output you sent me earlier.

or might be a userland issue (ethtool not reading the correct part?)
--=20
William

--eQyCKlb8USywWNtC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlKcgEcACgkQ1I6eqOUidQGYuACeOHzrfB8uLsrdN00AtgswmNhQ
52MAnjTxEWT/IyucfeY4UviA6ZdIwWdK
=cGPW
-----END PGP SIGNATURE-----

--eQyCKlb8USywWNtC--
