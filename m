From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2] e1000e: restore call to pci_clear_master()
Date: Wed, 12 Jun 2013 12:48:53 -0700
Message-ID: <1371066533.2133.41.camel@jtkirshe-mobl>
References: <20130612194408.8680.66934.email-sent-by-dnelson@teal>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uzQjBMcuYvi7meHHOlz/"
Cc: David Miller <davem@davemloft.net>,
	Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14441 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755290Ab3FLTtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 15:49:08 -0400
In-Reply-To: <20130612194408.8680.66934.email-sent-by-dnelson@teal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uzQjBMcuYvi7meHHOlz/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-06-12 at 15:44 -0400, Dean Nelson wrote:
> In attempting to resolve a minor merge conflict, commit
> e5f2ef7ab4690d2e8faa
> (Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net)
> accidently
> dropped a call to pci_clear_master() that was intended to remain in
> place.
>=20
> Commit 4e0855dff094b0d56d6b (e1000e: fix pci-device enable-counter
> balance)
> replaced a call to pci_disable_device() by one to pci_clear_master().
> And then
> commit 66148babe728f3e00e13 (e1000e: fix runtime power management
> transitions)
> deleted a number of lines starting two lines following that call.
>=20
> This patch restores the call to pci_clear_master() in
> __e1000_shutdown().
>=20
> v2: added summary lines (enclosed in parens) following commit IDs
>=20
> Signed-off-by: Dean Nelson <dnelson@redhat.com>
> ---
> Both stable 3.8.y and 3.9.y appear to have the call to
> pci_clear_master() in
> __e1000_shutdown() as desired.  I'm not sure how they avoided the
> conflict.
>=20
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
>  1 file changed, 2 insertions(+)=20

Thanks Dean, I will add this to my e1000e queue.

--=-uzQjBMcuYvi7meHHOlz/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRuNClAAoJEOVv75VaS+3OGA0P/04Kj2IkwllEum8s9MOmtPnz
rMi4tg44+PalgG3sfyuqgZZOPe9Pdjjiefj1H/M/cSCJSBN5VyfFecSyzHs9d53D
n0JXHxy11voH3gJIjDdH0zS/SJdq38ne61uCem/Su4BQIjmUk2OeJj0XtQPvssnT
lfoTxAnOx6nJ0CwwyQrCwIOTaEDbKhUSIIyxXO2H3oDsFXTn1gH/6f638FPvxE2J
PDTjVseQ5r3+2No2grbf35pVfSY2ONFYWgxn7PiGoMWK5Xf7Q3sAWev5o/6Z4uOG
rMy9b1OphsKHJgyQqoWS4y0ND6HeKifJudZ7P3naqTkRGWa3MHoixzuUiVnoRDun
orswdFbEZ0gznhaITSJOnHEdYJku5cNQKMyepCTt/Cqg/WJTvCGjHN/wYXXgxEiD
6fHkSvUXDeEtIrkAKwNx1IEaWNI4x4v0nkJipzirn9QwqGpP5DTVQRWwTL2fpFnL
64h7FuFyVmKhvXpD1KaUgjGWWYGO+xYhkaF1lzj8Qe7h6Z3/2CL2NcLzqPR3S7q6
BPwO8R8tMFbUYzYOk4E9Nbw3PU4Z4xiSBQRR+JTNCiY2V3ALotdcH0qJpECC1ja5
U8Eqa8ukiHY2YR+4Zd1hq9AsqeRMnfGNz1dyNwWJl2r7JAmp8xjaN813rJ9YoV7O
aTTPZNFyICdePribTo6X
=MqVJ
-----END PGP SIGNATURE-----

--=-uzQjBMcuYvi7meHHOlz/--
