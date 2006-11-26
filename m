From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 11:07:16 +0100
Message-ID: <1164535636.21459.7.camel@johannes.berg>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net> <45691273.9090803@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0808883891=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
In-Reply-To: <45691273.9090803-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============0808883891==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-E/nGr83SxsRybs4nWpxv"


--=-E/nGr83SxsRybs4nWpxv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2006-11-25 at 23:05 -0500, Daniel Drake wrote:

> Surely disabling the queue actually makes sense, in order to avoid=20
> frames designated for the "current session" being transmitted on=20
> different channels during scanning?

Also, for bcm43xx this isn't a problem since the firmware (optionally
but we use that afaik) takes care of not transmitting frames that are
tagged for a different channel than currently tuned to. This is
necessary because the packets travel through a FIFO and radio tuning is
done by the driver without it knowing how much is still in the FIFO and
a full disable is quite expensive (in terms of the time needed.)

johannes

--=-E/nGr83SxsRybs4nWpxv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFaWdU/ETPhpq3jKURAoumAJ0WMmCVcL4+xhEdUWTPcBr/zTMXsQCbBqOJ
FnfY3weMJg+W70bRRV7Fgfw=
=ZboS
-----END PGP SIGNATURE-----

--=-E/nGr83SxsRybs4nWpxv--


--===============0808883891==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bcm43xx-dev mailing list
Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/bcm43xx-dev

--===============0808883891==--
