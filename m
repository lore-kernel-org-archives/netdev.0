From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted to managed
Date: Thu, 4 Oct 2007 12:56:15 -0400
Message-ID: <200710041256.20995.flamingice@sourmilk.net>
References: <20071004113343.552139D502B@zog.reactivated.net> <20071004085440.008216c6@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3822380.ChMOfOQO4F";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071004085440.008216c6-s08KbqtN0aBORcJjwVk881hTQxXnIo14@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart3822380.ChMOfOQO4F
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 04 October 2007 11:54, Stephen Hemminger wrote:
> Playing with the function pointer is a awkward way to do this.  Shouldn't
> the state management flags be used instead (dormant, running, stop/wake).=
=2E.
> I am concerned about races and dereferencing the NULL ptr.
This is all under RTNL and the pointer is only modified while the interface=
 is=20
down.

=2DMichael Wu

--nextPart3822380.ChMOfOQO4F
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHBRs0T3Oqt9AH4aERAqhjAJwJwuirxBJEqpdxneUd2T0uLq2/CACfaMv4
wL/Xmkli1yjGD62ROVqXWZ8=
=7+ee
-----END PGP SIGNATURE-----

--nextPart3822380.ChMOfOQO4F--
