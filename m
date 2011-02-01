From: Antonio Ospite <ospite@studenti.unina.it>
Subject: Re: [PATCH v5 0/4] Adding HID Feature Report Support to hidraw
Date: Tue, 1 Feb 2011 12:47:30 +0100
Message-ID: <20110201124730.ac1faf74.ospite@studenti.unina.it>
References: <1295337880-12452-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__1_Feb_2011_12_47_30_+0100_SyiR/gWZILtkceNC"
Cc: Jiri Kosina <jkosina@suse.cz>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Michael Poole <mdpoole@troilus.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-input@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, Bastien Nocera <hadess@hadess.net>
To: Alan Ott <alan@signal11.us>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1295337880-12452-1-git-send-email-alan@signal11.us>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__1_Feb_2011_12_47_30_+0100_SyiR/gWZILtkceNC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Jan 2011 03:04:36 -0500
Alan Ott <alan@signal11.us> wrote:

> This patch adds Feature Report support for USB and Bluetooth HID devices
> through hidraw.
>=20
> The first two patches prepare the bluetooth side for the change.
> 	a. Make sure the hidp_session() thread is started before
> 	   device's probe() functions are called.
> 	b. Wait for ACK/NAK on sent reports, and return proper
> 	   error codes.
> The third patch is the hidraw core and USB changes.

In particular, this third patch is a prerequisite for the bluez
sixaxis-cable plugin, originally written by Bastien Nocera (added to
CC) which I plan to submit when these changes are merged in mainline
linux.

[...]

--=20
Antonio Ospite
http://ao2.it

PGP public key ID: 0x4553B001

A: Because it messes up the order in which people normally read text.
   See http://en.wikipedia.org/wiki/Posting_style
Q: Why is top-posting such a bad thing?

--Signature=_Tue__1_Feb_2011_12_47_30_+0100_SyiR/gWZILtkceNC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk1H8tIACgkQ5xr2akVTsAHjwACeOTUYIzHZTiJUum+6V7FtMEvN
C+sAnjeBZ1nBbI+A7/ZZo6fGluN39I68
=aGvS
-----END PGP SIGNATURE-----

--Signature=_Tue__1_Feb_2011_12_47_30_+0100_SyiR/gWZILtkceNC--
