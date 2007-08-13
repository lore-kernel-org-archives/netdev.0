From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/4] Net: mac80211, remove bitfields from struct
	ieee80211_tx_packet_data
Date: Mon, 13 Aug 2007 14:43:49 +0200
Message-ID: <1187009029.27916.107.camel@johannes.berg>
References: <32694265142306417777@wsc.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7G5E77YaV8ejdTKXdGhu"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbenc-AlSwsSmVLrQ@public.gmane.org, flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
To: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <32694265142306417777-2EuRcrBQ8V0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-7G5E77YaV8ejdTKXdGhu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-08-12 at 15:08 +0200, Jiri Slaby wrote:

> +	if (control->flags & IEEE80211_TXCTL_REQ_TX_STATUS)
> +		pkt_data->flags |=3D IEEE80211_TXPD_REQ_TX_STATUS;
> +	if (control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT)
> +		pkt_data->flags |=3D IEEE80211_TXPD_DO_NOT_ENCRYPT;
> +	if (control->flags & IEEE80211_TXCTL_REQUEUE)
> +		pkt_data->flags |=3D IEEE80211_TXPD_REQUEUE;
> +	if (control->type =3D=3D IEEE80211_IF_TYPE_MGMT)
> +		pkt_data->flags |=3D IEEE80211_TXPD_MGMT_IFACE;

This looks weird. Can't we just use the same flags?

johannes

--=-7G5E77YaV8ejdTKXdGhu
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGwFIF/ETPhpq3jKURAjXCAKCg1zYXY3Xvcl8v4bea/6pHod8yUgCgorwG
DaD5jjbBjNVxZdrxjVy9OMY=
=Wwrs
-----END PGP SIGNATURE-----

--=-7G5E77YaV8ejdTKXdGhu--
