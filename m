From: Nico Schottelius <nico-linux-20111017@schottelius.org>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 23:42:50 +0200
Message-ID: <20111019214250.GC2432@schottelius.org>
References: <20111019123602.GA11883@schottelius.org>
 <1319028563.8416.1.camel@edumazet-laptop>
 <20111019130749.GD11883@schottelius.org>
 <20111019142837.GA1414@schottelius.org>
 <4E9EE20F.1030403@broadcom.com>
 <20111019145501.GB1414@schottelius.org>
 <4E9EFF51.6000104@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zx4FCpZtqtKETZ7O"
Cc: Nico Schottelius <nico-linux-20111017@schottelius.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E9EFF51.6000104@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zx4FCpZtqtKETZ7O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Arend van Spriel [Wed, Oct 19, 2011 at 06:48:17PM +0200]:
> On 10/19/2011 04:55 PM, Nico Schottelius wrote:
> commit bee709ab1d390afe69e4407bc86bb706c6fb2965
> Merge: ad1c761 1f2c7e9
> Author: Nico Schottelius <nico@kr.ethz.ch>
> Date:   Tue Oct 18 00:04:05 2011 +0200
>=20
>     Merge branch 'fix-edp-vdd-power' of ../keithp/linux
>=20
> As it drops receive packets it may be your problem. Is your AP on 5GHz?

I've to confess I've no clue, but I guess the answer is "some of them":
Here in ETH Zurich (www.ethz.ch) I'm in an environment with a lot of
surrounding APs (probably 7 or more seen with the same ssid).

> From 7d14bd6cbfbf26369c5958e56a468fd8429841d7 Mon Sep 17 00:00:00 2001
> From: Arend van Spriel <arend@broadcom.com>
> Date: Wed, 19 Oct 2011 18:42:45 +0200
> Subject: [PATCH] staging: brcm80211: fix for rate index in receive status

Applied, recompiling, will test tomorrow.

I'll soon (Friday) leave the environment permanently,
thus testing will not be easily possible anymore.

If this issue is 5Ghz related only, can I somehow trigger it without an AP
running in that band / i.e. make the card try to use the 5 Ghz band although
there is no ap nearby?

Cheers,

Nico

--=20
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0

--zx4FCpZtqtKETZ7O
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk6fRFoACgkQ19zI5DGHffCPQACg15iCJw4KEF66Mxa6BlIxnMQv
uN4An1HgNT32hDs9fuNn2QgXxYnP8HIT
=NE8g
-----END PGP SIGNATURE-----

--zx4FCpZtqtKETZ7O--
