From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 16:54:26 +0200
Message-ID: <1254322466.3959.5.camel@johannes.local>
References: <200909111648.50902.mb@bu3sch.de>
	 <20090929192928.GF2678@tuxdriver.com> <4AC3475C.7000403@hartkopp.net>
	 <200909301633.04376.mb@bu3sch.de>  <87ocosqykb.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-ZMVAfkYVX3YpIa63so4V"
Cc: Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kalle.valo@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51961 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbZI3Oy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 10:54:27 -0400
In-Reply-To: <87ocosqykb.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZMVAfkYVX3YpIa63so4V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-09-30 at 17:47 +0300, Kalle Valo wrote:

> I agree with Michael. The bug is real and I have verified that
> Michael's patch fixes the issue. Better to apply the patch now, it's
> trivial to change the implementation if/when the network stack has
> support for this.

FWIW, I think in mac80211 the in_interrupt() check can never return true
since we postpone all RX to the tasklet. But the tasklet seems to be ok
-- so should it really be in_interrupt()?

johannes

--=-ZMVAfkYVX3YpIa63so4V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKw3EeAAoJEODzc/N7+QmaOMQP/3hf8jDqWyigHUANoR8sQ0oq
jgy31FwyaKBpYfSKYM1yscK01lOq90dcbc93HG3CS8zW27w+b2mVeJeR7bvKM0xo
cn7hhiEvli3ILGjRRRHPDSrV78+bzltYwwd0DiYsDlmfhTkj06myg6P5DeZhrJnQ
CiufPFNdS6z+qyzBvT9ck0STpFe0RV2PHD5X4DQbkpSNKBHs6nqnmOyQKw8dOXpV
v7MZm6c7nFnSYyVgDaDFFuogQROquC6JtAOebaMzoX2vXbT1uKTd8wj3HbErOuAl
A/3Hfj7Kt8bmCF06CRvECLqXLonzgdaDJJu7hxIH2/2ei4ktQv+M6s92xEkGKLNT
RxLffZfjKR+0rcOJfe87qxujR6kLZpWoaCgyU2zaS3dJyUlz77y36g7iXwSNPXQp
f5qLpeZhH7RFjqOt4wbWOiPVCzfK2SIWduGRfX7aS99B+QpfcoKBGoeD6e0uO65q
4+ijLRIpdga/QrW/SmyNI/GN+H1IIUUxxOSHYsX8GjTR6dmkG0o8ZMfsRyql+2iD
WNSLs3YX53tNh/JaC1/eUMQ0/V22wqdhnC6tUw8oYIpNFFmmKVOHSTVvx65BfaxE
ZBNHBrFEhMECQmHzVpmkZMAFKqrWmF2mJn/tcQJJIQCm6dvm7fCwnvqSpnbQGemv
xycWAhAke+IYQGmVmFqi
=gA4z
-----END PGP SIGNATURE-----

--=-ZMVAfkYVX3YpIa63so4V--

