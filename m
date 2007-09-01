From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: borkage in 2.6.23-rc4-mm1
Date: Sat, 01 Sep 2007 11:02:00 +0200
Message-ID: <1188637320.7585.113.camel@johannes.berg>
References: <20070831211603.083dfed2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+U5vBy10wFSh3oOs34LL"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070831211603.083dfed2.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-+U5vBy10wFSh3oOs34LL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-08-31 at 21:16 -0700, Andrew Morton wrote:
> Am seeing random crap like this:

> Aug 31 20:58:07 sony kernel: ipw2200: Firmware error detected.  Restartin=
g.

> Aug 31 21:01:31 sony kernel: ipw2200: Firmware error detected.  Restartin=
g.

> when trying to use ssh on the current rc4-mm1 lineup.

Very odd. I don't recall any patches touching the ieee80211 code though
I'm not entirely sure (last I saw was DIV_ROUND_UP from net-2.6.24). Are
you using WPA/RSN? ISTR I posted about a bug in the ieee80211 code a
while ago but I don't think it should make the ipw2200 firmware upset.

johannes

--=-+U5vBy10wFSh3oOs34LL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG2SqH/ETPhpq3jKURAtAMAKCMkESVauKsMxlhh+r57zqrm8f2gQCfci14
GuiTiSUA7Nkal3m+nXW64j0=
=FEoY
-----END PGP SIGNATURE-----

--=-+U5vBy10wFSh3oOs34LL--
