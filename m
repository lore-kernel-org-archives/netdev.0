From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless tree with the net tree
Date: Fri, 9 Jul 2010 11:51:19 +1000
Message-ID: <20100709115119.6c88f8d2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__9_Jul_2010_11_51_19_+1000_+ybeaPsdpAXC7QsI"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__9_Jul_2010_11_51_19_+1000_+ybeaPsdpAXC7QsI
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless tree got a conflict in
drivers/net/wireless/wl12xx/wl1271_cmd.h between commit
ba2d3587912f82d1ab4367975b1df460db60fb1e ("drivers/net: use __packed
annotation") from the net tree and commit
34dd2aaac4a4b908c093980a9894fd878aeb6deb ("wl1271: moved scan operations
to a separate file") from the wireless tree.

I didn't bother changing __attribute((packed)) to __packed where this
code has been moved to.  Maybe someone could write a patch to do that ...
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__9_Jul_2010_11_51_19_+1000_+ybeaPsdpAXC7QsI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMNoCXAAoJEDMEi1NhKgbswMwH/1rRe2pRvN2JB6Wge38UYGww
CXJUsjTUkPGK7ve2HDtBlbPcZv8Ow3iO/aTYWawYqjJRYZdVZr7ocmYgFGu5AiZE
Wc2l429G4tGnFp6zDJbxIGPBVtrEujAgnTT56JxzzeRwkKehQRtrhv4GFB9L059t
d5rZv8vcoVCJYoVzqOLNyS19YfWsVKejHZj1dHsMxBsbRDEqaRa+KJFXTmGnV7vX
yPEkJ210wFubBLh7Zsq2E2D0D2mZKuJ+h8vN9TfLfSD9TR6XQ2deGMl8T+IHWTqN
MBefMG14XDZhtpIjQuFmuU7AOUG9NlhMq3slile+TY/k3q/pydTGFbQKcOePaXs=
=e7Pn
-----END PGP SIGNATURE-----

--Signature=_Fri__9_Jul_2010_11_51_19_+1000_+ybeaPsdpAXC7QsI--
