From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 1/4] can: kvaser_usb: Don't free packets when tight
 on URBs
Date: Thu, 08 Jan 2015 10:59:41 +0100
Message-ID: <54AE550D.2090603@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150105174910.GA6304@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="WiNE8xaUfGDPeWqvKbbP7HCNwqTlFEQ4v"
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150105174910.GA6304@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WiNE8xaUfGDPeWqvKbbP7HCNwqTlFEQ4v
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/05/2015 06:49 PM, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>=20
> Flooding the Kvaser CAN to USB dongle with multiple reads and
> writes in high frequency caused seemingly-random panics in the
> kernel.
>=20
> On further inspection, it seems the driver erroneously freed the
> to-be-transmitted packet upon getting tight on URBs and returning
> NETDEV_TX_BUSY, leading to invalid memory writes and double frees
> at a later point in time.
>=20
> Note:
>=20
> Finding no more URBs/transmit-contexts and returning NETDEV_TX_BUSY
> is a driver bug in and out of itself: it means that our start/stop
> queue flow control is broken.
>=20
> This patch only fixes the (buggy) error handling code; the root
> cause shall be fixed in a later commit.
>=20
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> Acked-by: Olivier Sobrie <olivier@sobrie.be>

Applied 1-3 to can/master + added stable on Cc.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--WiNE8xaUfGDPeWqvKbbP7HCNwqTlFEQ4v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUrlUNAAoJECte4hHFiupUU1oP+gPHJr/qMlLDH/fU+ewPD1Mz
51hu2buq6BT2SR1EGf5Hnn4HiQc4GFp8WfSxiSpUX7KggpTefig/XApe4JEj/dUE
Glr3ef0yyrruQpWyqCnohWtJH099ejGwvNhKtVXckPj4eBt9gLOMXat7iTf1Bccx
YLqEv+TKKt+cVKasFZVxSuUJSazK1hGblP4mJrwXEsjjfFiOSExdMVcoANK4QGZa
rTYLULlNNr/kgGRNyHwjTgSMOqiSIb7jroiHETp2rO0Odo/hbxm9SfTSUTGhACs+
N0X2qHdMfyThPR18fbpCYnBlLoLm08N++EmLt+v43biN8Gwqh9a91hva4sI5rOnO
cyUCO6OJ/WQAqEOsGQXtmQ8c1ziZSTraECnYi1d9PQi2AyLqo+m33Ou1gjPV3jcw
J2hh7l4kbKTbgbgQLHyjdk0lAFrvUogYMA/9vy9hLEMaiknD5QflnC9N02I5DTGe
MC5/n0n72qz4yhfv4p+Tm63eqiH6AiWnNyAYZLd7h3pztWa+0pdy5HOuYT92Coff
YaWQ7pMhrA/UBjj1qPQXnLVmJgHrwnnw9iNSlTD0tV7IyCCMx9wD2hNfYsi9as9I
q8hWQpJI1bHcKziqMFR8a5pm/4/9u8gjgfQvrx3oK5qWSiYyjkuVpQUD3KAd7Zsd
g9uabkR6ZybKwICbLCbO
=xNks
-----END PGP SIGNATURE-----

--WiNE8xaUfGDPeWqvKbbP7HCNwqTlFEQ4v--
