From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Patch net] igb: pass the correct maxlen for eth_get_headlen()
Date: Fri, 24 Apr 2015 18:07:20 -0700
Message-ID: <1429924040.2644.63.camel@jtkirshe-mobl>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hDdCDXEQ+soiS0KPDEyq"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40038 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031198AbbDYBHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2015 21:07:23 -0400
In-Reply-To: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hDdCDXEQ+soiS0KPDEyq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-22 at 10:45 -0700, Cong Wang wrote:
> The second parameter of eth_get_headlen() is the length of
> the frame buffer, not the header length of skb.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Dropping this patch based on feedback from Alex.

--=-hDdCDXEQ+soiS0KPDEyq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVOujIAAoJEOVv75VaS+3OpW8P/A3tgOhQEPjfhBoUy99g52cU
ItepgLn3VLkB81gLa4uy2ObpTnJwCY3UxAqsOyimc9pvuCTqOCa1h2ugz6o31uC4
OEkTxFcBbNFBOrh2usaXfzYtBJFY8hfJocCUek2j6o3wcTYQPfNrU0yBYapxRA5N
bMljJPV2Bw00PoS7HNO0t4CUNcZ0nmxi4L0EgIZkBZwumKCLfkfdBPOU4FSfNdDG
/IfP0jyHJ/GCM4NRL06VXgpPsGlsZoZM1Gl+swSjIQtJpBPlD92cZVG65PpdH3OC
ufdw+PVirwg4CqKxYy4jI/1afHBDIwT4MZgbykEkEzq2FQMQSZmnDio+JeNaVrSU
bBNZEhXbBmGERxm80icGj8RCV5com30z+3yTxkX0fhFcci/x7BBAK51/+/lZGlOw
ZD2c4EUW63EZTmBWRJ+Uedkk/ETyTeotMYMXkfnErP+DlmYfCDribRtXZV1JU4Ic
QoMG+T4p4Krm/oYicorC1eQfcTVDVv3s2xhPKdgpYm51vqBv0UcnPn9msDzKDWmC
DC/XdgMu/qOfu7SYEtWiKI0LSc3i1HMs++K7EbX2frPfV/B2rS8s/DJ2lNLj1/qN
d5rj1LVInyRREK/GKGpF1i1rACYuRzKTOMizDu5YfBJhvILJX5Ma1nf8hX3ZJK7Q
sidSLXJpDE5WBs/G25z0
=84fD
-----END PGP SIGNATURE-----

--=-hDdCDXEQ+soiS0KPDEyq--
