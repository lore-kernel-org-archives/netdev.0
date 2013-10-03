From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: pull request net: 2013-10-02
Date: Thu, 3 Oct 2013 22:14:13 +0200
Message-ID: <20131003201413.GC3668@neomailbox.net>
References: <1380744201-2074-1-git-send-email-antonio@meshcoding.com>
 <20131003.155802.929707046474176566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="f2QGlHpHGjS2mn6Y"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([178.209.62.154]:39817 "EHLO
	s2.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754976Ab3JCUOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 16:14:38 -0400
Content-Disposition: inline
In-Reply-To: <20131003.155802.929707046474176566.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 03, 2013 at 03:58:02PM -0400, David Miller wrote:
> From: Antonio Quartulli <antonio@meshcoding.com>
> Date: Wed,  2 Oct 2013 22:03:20 +0200
>=20
> > this is a "one-change" pull request intended for net/linux-3.{12,11,10}.
> >=20
> > This patch from Matthias Schiffer is fixing the init routine of the Net=
work
> > Coding component by preventing it from registering the handler for the =
CODED
> > packet type each time a new soft-interface is created.
> >=20
> > Without this fix a second soft-interface cannot be created unless the N=
etwork
> > Coding component is not part of the module (not compiled-in).
> >=20
> > As I mentioned before, this fix should be queued for stable as it aims
> > kernels older than linux-3.12.
> >=20
> > Please pull or let me know of any problem.
>=20
> Pulled, thanks Antonio.
>=20

David,

please consider queuing the patch for stable as it is rather important (if =
you
already did so then I can't see this in patchwork).


Regards,


--=20
Antonio Quartulli

--f2QGlHpHGjS2mn6Y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSTdAVAAoJEADl0hg6qKeO6F4P/0BkHALnFtITpyjlNyC23AY2
kAwZQ8NgbvMX6ObfZ2YtLCSYv5FlqRAXzTrHWjzuMsqup6B1alNZYOQbs7dRfb5V
CCELyJ8czJff6cYwFcpletwfkGIDcIPzqgZGBaEA1+i4G/f890Vs1ZT46V5CDPCS
0MAncXLOl6EJjyxVC8tZXeLwXFTnnHhz8WxPwNBCaiwmFxTCwnBWyG/xspGC8s/p
w7/WLk9tOL/YfGxfTqHtZ4xG6nFbsFV/iSYjt7ayjBFwrJzlayxO0W1eaNLqVqGc
ymzANvrTWNvfqlPEhgiSmsH6KdP6ONGi2jKiIuoQUi+r9vzB76WhrB3GKdkeuuYw
uT0HAYTe4tqiI3d5LDmQVESXvRbWQRhWllFo5SrXsbyLPzmPMT2H3CHjIuamfieG
rfuB/+SEfAIuWjk9cSPAW1h9h78F2Ub3Mq7jMLTpdgqnCBO9OL8d3ZtfyU8E6fuE
uWQmN/aKEtNBCP8YaO9C5ZqnZYIMeTmWP/dkum6w7Vz2Lva9BUUcuc3bnzPa5ikE
kIZDIIwppGF2R5cO8+ldMGCJmpOJerADtasrtFuf5UYNBss4XGvzaC/1zy1WvwCe
W4Jf8lPRH4rgylQQjhmMRtrvJMz0aI0/FzkqwmNj0knBgq5rBzAoPBdr7dW5u2w8
HuYy12+seJWwD7lyIqzj
=fkuP
-----END PGP SIGNATURE-----

--f2QGlHpHGjS2mn6Y--
