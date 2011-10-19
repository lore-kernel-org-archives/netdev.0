From: Nico Schottelius <nico-linux-20111017@schottelius.org>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 16:55:01 +0200
Message-ID: <20111019145501.GB1414@schottelius.org>
References: <20111019123602.GA11883@schottelius.org>
 <1319028563.8416.1.camel@edumazet-laptop>
 <20111019130749.GD11883@schottelius.org>
 <20111019142837.GA1414@schottelius.org>
 <4E9EE20F.1030403@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aVD9QWMuhilNxW9f"
Cc: Nico Schottelius <nico-linux-20111017@schottelius.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, wey-yi.w.guy@intel.com
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E9EE20F.1030403@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--aVD9QWMuhilNxW9f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey Arend,


Arend van Spriel [Wed, Oct 19, 2011 at 04:43:27PM +0200]:
> I actually don't see the rtnl_lock or mutex_lock that was listed in your
> original dmesg. There are a lot of warning traces from mac80211.c.

Oh, sorry, ip r was stuck already and I didn't wait 120 seconds!


> The other interesting thing is the following:
>=20
> [  367.389096] wlan0: deauthenticating from 00:03:52:e3:0e:10 by local
> choice (reason=3D3)
> [  367.416312] cfg80211: Calling CRDA to update world regulatory domain
> [  369.367667] wlan0: direct probe to 00:03:52:2c:01:00 (try 1/3)
> [  369.565008] wlan0: direct probe to 00:03:52:2c:01:00 (try 2/3)
> [  369.764891] wlan0: direct probe to 00:03:52:2c:01:00 (try 3/3)
> [  369.964768] wlan0: direct probe to 00:03:52:2c:01:00 timed out
> [  381.310339] wlan0: direct probe to 00:0f:61:1a:0c:50 (try 1/3)
> [  381.508071] wlan0: direct probe to 00:0f:61:1a:0c:50 (try 2/3)
> [  381.707955] wlan0: direct probe to 00:0f:61:1a:0c:50 (try 3/3)
> [  381.907788] wlan0: direct probe to 00:0f:61:1a:0c:50 timed out
> [  393.250073] wlan0: direct probe to 00:03:52:2c:01:00 (try 1/3)
> [  393.447810] wlan0: direct probe to 00:03:52:2c:01:00 (try 2/3)
> [  393.647700] wlan0: direct probe to 00:03:52:2c:01:00 (try 3/3)
> [  393.847576] wlan0: direct probe to 00:03:52:2c:01:00 timed out
> [  405.183177] wlan0: direct probe to 00:0f:61:1a:1d:30 (try 1/3)
> [  405.380906] wlan0: direct probe to 00:0f:61:1a:1d:30 (try 2/3)
> [  405.580773] wlan0: direct probe to 00:0f:61:1a:1d:30 (try 3/3)
> [  405.780658] wlan0: direct probe to 00:0f:61:1a:1d:30 timed out
>=20
> There is another thread title "iwlagn is getting very shaky". It makes
> me wonder.
>=20
> Where did you get your kernel from. From you dmesg I see:

It's a mix of Keith's and Jiri's branches:

http://www.nico.schottelius.org/blog/macbook-air-42-touchpad-keyboard-corre=
ct-screen-resolution/

Those two are needed to get screen/keyboard/mouse working on the MacBook Ai=
r.

You can pull the merged result directly from

  git://git.schottelius.org/foreign/linux-keith-jiri-mba

Cheers,

Nico

--=20
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0

--aVD9QWMuhilNxW9f
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk6e5MUACgkQ19zI5DGHffBr0wCeM96ozFmOYLKh1B+U0EaeIy3p
JXkAnim2zo3iXin25eIHBdvHPGLpQ1Jc
=9rDo
-----END PGP SIGNATURE-----

--aVD9QWMuhilNxW9f--
