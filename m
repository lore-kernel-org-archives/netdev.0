From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] ieee80211_if_set_type: make check for master dev more explicit
Date: Thu, 4 Oct 2007 17:26:11 -0400
Message-ID: <200710041726.11744.flamingice@sourmilk.net>
References: <20071004113343.552139D502B@zog.reactivated.net> <20071004180900.GG6037@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2193734.nSyxz73F79";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071004180900.GG6037-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart2193734.nSyxz73F79
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thursday 04 October 2007 14:09, John W. Linville wrote:
> diff --git a/net/mac80211/ieee80211_iface.c
> b/net/mac80211/ieee80211_iface.c index be7e77f..6607b80 100644
> --- a/net/mac80211/ieee80211_iface.c
> +++ b/net/mac80211/ieee80211_iface.c
> @@ -106,7 +106,7 @@ void ieee80211_if_set_type(struct net_device *dev, int
> type) * which already has a hard_start_xmit routine assigned
>  	 * which must not be changed.
>  	 */
> -	if (!dev->hard_start_xmit)
> +	if (dev->type != ARPHRD_IEEE80211)
The standard way of checking for the master device is
dev == sdata->local->mdev

wme.c doesn't quite follow this but that code needs to die anyway.

This does look nicer than the other patch.

-Michael Wu

--nextPart2193734.nSyxz73F79
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBHBVpzT3Oqt9AH4aERAhzbAKCVUUi42jfCZfPcf7VrO1d6AGaG6gCgqZna
Saxfk2SRBLpjRoaQF2k5AVI=
=/YjF
-----END PGP SIGNATURE-----

--nextPart2193734.nSyxz73F79--
