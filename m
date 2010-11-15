From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Add Flow
	control,
Date: Mon, 15 Nov 2010 10:11:06 +0100
Message-ID: <4CE0F92A.40308@pengutronix.de>
References: <4CE0EFA7.9020007@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6855660425389560139=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CE0EFA7.9020007-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============6855660425389560139==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig837C208F5ECAE2AD23298E98"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig837C208F5ECAE2AD23298E98
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/15/2010 09:30 AM, Tomoya MORINAGA wrote:
>  * Add Flow control
>  * Fix Data copy issue (endianness)
>  * Add Macro prefix "PCH_"
>  * Separate interface register structure
>  * Some functions are unified.
>  * Change MessageObject indication(PCH_RX_OBJ_START, etc..)
>  * Enumerate LEC macro
>  * Move MSI processing from open/close to probe/remove processing
>  * Use BIT(x)
>  * and more...

Please make it one patch per topic. A review of your patch will follow.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig837C208F5ECAE2AD23298E98
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzg+S4ACgkQjTAFq1RaXHMgIwCfXwePmvqOFLnytV6I1CzxNvWI
1+sAn0fS+NBszgu5O6SUVUBItwe4+WXC
=zJi5
-----END PGP SIGNATURE-----

--------------enig837C208F5ECAE2AD23298E98--

--===============6855660425389560139==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============6855660425389560139==--
