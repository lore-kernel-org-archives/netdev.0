From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/6] d80211: change the cookie to be opaque
Date: Fri, 03 Nov 2006 01:46:31 +0100
Message-ID: <1162514791.3381.14.camel@johannes.berg>
References: <20061102223854.692274000@sipsolutions.net> >
	 <20061102230013.960383000@sipsolutions.net> >
	  <1162513367.3381.11.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2QCIAhctxuSpwYyI99mT"
Cc: netdev@vger.kernel.org, Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38528 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752748AbWKCArz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 19:47:55 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <1162513367.3381.11.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2QCIAhctxuSpwYyI99mT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Ok, that one was wrong. But what is it doing in the public API? We need
> to remove it from the public API and leave struct net_device *dev as the
> parameter. adm8211 actually uses it and increases the tx_fifo_error
> counter, but that's a bit strange.

Fixed, and since, as always, netdev doesn't like my patches, they're
here instead:

http://johannes.sipsolutions.net/files/d80211-mdev-cleanup/

I also added d80211-reduce-mdev.patch which reduces stupid mdev usage,
but see the description in the patch itself.

johannes

--=-2QCIAhctxuSpwYyI99mT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUqRZqVg1VMiehFYAQKFAxAAjG4EGT9Wr/e+sSMt0OH5ZcellaZpcXBm
Kgb1QbjpJdR4ETatGcQnt5JCRHUwglNmlLWCZoDVYdCk/Q2ls5uSQZXNWpdkQpkn
69m1oF7t8jp+G7EKtY7LtxKgiV4Z1Htpg73sCr462bT8luhURklMvEJjlEyNcYE8
AdEsOl+KHR/XRW3F6xn3XImwFk3ymv45PgcylgpH/C6BsZnHznv7jRKB7z2WEboD
s7phg3shy8KD4QdGIA1plgqNJvNJoFrUJK6Vs3QO1kzNP84MrkfN3qS3MgoZYWsO
xA4Pf9ZMIdDN+xfrFL1VASJ5wPavZsP7/BgqPc80XcrhwZbp7lnHsHbc4PSFFuc5
2iVLOBzobxiGAJM/g9TLBtm+bZzJ3/7ETdBrNFs1HE9SZi+i4qrJq7Mm1AbZW/HE
Lfw0UdWOHCqicYrEc/x+0Fkjdh52YR3bG80Yk4jP/bthZ5ZH7Oq01qyxFrUj5UJa
frGeNhusg26v1Xg38l36+smO2T0ow04DZkbsqf0EiIHUyZ4WQhA5ccrMkgRX4jN3
791cYTuvV0ArmSlH0ROvQf76StiofyoeTqozaQChx6aOHFn75J40oUPE7rXeTrf9
Si2lbztLRoabJC3r/0hyE5TCDrhJNVm2L4MfuXlKxq2f68GGDLoc8d5Le/ka435Y
gtoPIKeCZSA=
=Qmap
-----END PGP SIGNATURE-----

--=-2QCIAhctxuSpwYyI99mT--

