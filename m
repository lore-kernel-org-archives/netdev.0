From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 2/4] Net: mac80211, remove bitfields from struct
	ieee80211_txrx_data
Date: Mon, 13 Aug 2007 14:44:38 +0200
Message-ID: <1187009078.27916.109.camel@johannes.berg>
References: <2653412025907217317@wsc.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QDS0UPsfdZM3iz18bE18"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbenc-AlSwsSmVLrQ@public.gmane.org, flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
To: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2653412025907217317-2EuRcrBQ8V0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-QDS0UPsfdZM3iz18bE18
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-08-12 at 15:08 +0200, Jiri Slaby wrote:

> -	unsigned int fragmented:1; /* whether the MSDU was fragmented */
> +	/* whether the MSDU was fragmented */
> +#define IEEE80211_TXRXD_FRAGMENTED		BIT(0)
> +#define IEEE80211_TXRXD_TXUNICAST		BIT(1)
> +#define IEEE80211_TXRXD_TXPS_BUFFERED		BIT(2)
> +#define IEEE80211_TXRXD_TXPROBE_LAST_FRAG	BIT(3)
> +#define IEEE80211_TXRXD_RXIN_SCAN		BIT(4)

I know this isn't the style currently used, but could you put these
definitions before the struct declaration? That way, kerneldoc doesn't
totally screw up.

johannes

--=-QDS0UPsfdZM3iz18bE18
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGwFI2/ETPhpq3jKURAqoiAJ9TudBaJ7/wz8RydKNs9NzyH0S0XgCgi3MF
2U/c9xHgn70Ysvo21XVdnnM=
=iHUh
-----END PGP SIGNATURE-----

--=-QDS0UPsfdZM3iz18bE18--
