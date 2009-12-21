From: Andrey Rahmatullin <wrar@altlinux.org>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Mon, 21 Dec 2009 23:18:40 +0500
Message-ID: <20091221181839.GA5232@wrars-comp.wrarsdomain>
References: <20091219111206.GA5307@wrars-comp.wrarsdomain>
 <20091220200343.GA5427@wrars-comp.wrarsdomain>
 <alpine.DEB.2.01.0912210352200.3483@bogon.housecafe.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="0OAP2g/MAC+5xKAE"
Cc: LKML <linux-kernel@vger.kernel.org>, Roger Luethi <rl@hellgate.ch>,
	netdev@vger.kernel.org
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756238AbZLUSSq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.01.0912210352200.3483@bogon.housecafe.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 21, 2009 at 04:03:06AM -0800, Christian Kujau wrote:
> In the .jpgs one can see something along the lines of=20
> schedule_timeout, napi_disable, rhine_tx_timeout - the only patch I could=
=20
> find touching these things [1] altogether is rather old, from 2.6.24. Is=
=20
> 2.6.29 working for you?=20
I've installed 2.6.27, the earliest kernel supported by udev 149. I
started to download two large files to my second machine (maybe 700 or
1000 Kbyte/s combined). Nothing happened. I stopped the downloads and
started deluged. The kernel showed "netdev watchdog timeout", but nothing
else happened. deluged opened something like 100 TCP connections and
started to upload some data at ~20 Kbyte/s. Nothing happened. I resumed
one of downloads, waited for some time, nothing happened. I resumed the
second download, the kernel crashed into an endless stream of backtraces
(did 2.6.27 support pause_on_oops?), containing "whatever from the idle
thread", or smth like that, which was also in other crash logs.

--=20
WBR, wRAR (ALT Linux Team)

--0OAP2g/MAC+5xKAE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBCAAGBQJLL7v/AAoJEOih81koZvPB8gUIAJmID1m6CAMCbowGQusATYdc
yGMQCXw8XXpzbH25vRwpWBMTiGVrsF/Wfnuk/bq6pHf2vMw4xFuOcIsJoWagb5Pn
p0bRspYFV9lltRyE/5b1hNjhAljnfXjO0znL2Wrx5ylYzc5reNKhw5pH/IzVNT8E
af62iJbxiEdIyHmr8lYBDAQIE8H7ThYYFQXSRYbu06CDGHDPQ7azgAkB88GFI1ls
DxlKJFqNzeqOy3sG+63Gf/3GNRXZjGsTPBBDo9aJ10fJLK3hti8FU/Xem510xc8n
DP36wIZqJzk1U5W9MHCthvX0NbUj+4hL39VN+kJsKILyBlqf6w9kZJRpLmC5bpw=
=I4vV
-----END PGP SIGNATURE-----

--0OAP2g/MAC+5xKAE--
