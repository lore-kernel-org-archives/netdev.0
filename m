From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] cfg80211: fix wireless handlers assignment
Date: Mon, 28 Sep 2009 11:29:39 +0200
Message-ID: <1254130179.6583.21.camel@johannes.local>
References: <1254126117.6583.19.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-9X0nEpfe4IJA6fRaYfpU"
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43359 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbZI1J3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 05:29:53 -0400
In-Reply-To: <1254126117.6583.19.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9X0nEpfe4IJA6fRaYfpU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-09-28 at 10:21 +0200, Johannes Berg wrote:
> The point we assign dev->wireless_handlers at is too
> late, we need to do that before netdev_register_kobject()
> gets called, so use the new NETDEV_PRE_INIT notifier.
> The result of adding wireless_handlers too late is the
> disappearance of /sys/class/net/wlan0/wireless which a
> bunch of distro scripts still require.

Ignore please, I have a better, self-contained fix.

johannes

--=-9X0nEpfe4IJA6fRaYfpU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKwIIAAAoJEODzc/N7+QmaGhcP/iA023BLXtzstg1qNJgRdiQu
vJmJag3jMJZrZ99EvfbaNewsBs5SV95m5vhVNQiUrEKrAHwcOwFJvftKUd2TW7Fo
QfM5haFNfmTTkMuFZRQrhYJmZ3SXwoZk4HUsQJQ0TiaPwLjsCjJq7/FCruT2h54q
emo3rc3qURx9tWYLiOG3i67kR6EviyoWDAr9ESFvQtxRisIb4JD9xozWCcn/D2vN
vcUQrEOoSt6DsNjbGpspGD/pQmxM92jq9ttDqGLzdqlcPcaS/L1RXkXzR8UBCBzY
4iWZHGKyHFSngPuDXL85Ce0/rcTg0+oXi+qx+q2CPekfsTPbfrqcDGN1ab6uik7B
X6Sq5mZe5AsyqC1gYms0fITm7EJTmCGaEkG4XHGXOzw5NMZbUT9Z3si4TtoChuVQ
I0rfgiTEVRQmr7w1pO+nFbcHNBWjLfjO69ijzzhVLIyCifjDYP6kOXZzmYjmcULJ
d7y9fCtQOh1ig/xNXkI5sf/7ByvfYTzhU1i5HvvRIkeSYnfI7otW76NEY8KklCJy
MQXCp8BwsOotTgjU4mRQ5ToBOO/ZllKweVxUochr0CMZ36papIprdCjuToSd6K1f
FAxIEgNAQvb2IFUvlW+8S5rluO5xbLTWCEtY+hpAR6bxxagDTcRdZguf9XlP/r80
plbNre9tXoR8xLT7Sp+R
=5ffI
-----END PGP SIGNATURE-----

--=-9X0nEpfe4IJA6fRaYfpU--

