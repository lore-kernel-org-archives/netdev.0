From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#595265: linux-image-2.6.32-5-686: Nerwork card fails to
 come up again after suspend
Date: Mon, 18 Oct 2010 01:23:51 +0100
Message-ID: <1287361431.20865.133.camel@localhost>
References: <20100902154312.12515.10390.reportbug@bird.umass.edu>
	 <201009211624.12744.aboelens@engin.umass.edu>
	 <1286760421.2955.287.camel@localhost>
	 <201010171116.00514.aboelens@engin.umass.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-49olpW7JNXCObFxOuBic"
Cc: Arnout Boelens <aboelens@engin.umass.edu>, 595265@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32997 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751830Ab0JRAYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Oct 2010 20:24:01 -0400
In-Reply-To: <201010171116.00514.aboelens@engin.umass.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-49olpW7JNXCObFxOuBic
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Arnout Boelens reported that his RTL8111/8168B fails to link-up after
suspend and resume, both under Debian's kernel based on 2.6.32 and under
2.6.36-rc6.  Full details are at <http://bugs.debian.org/595265>, though
the log isn't very informative:

[31837.396594] PM: Finishing wakeup.
[31837.396597] Restarting tasks ... done.
[31840.267267] r8169: eth0: link down

Can you suggest how to investigate this further?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-49olpW7JNXCObFxOuBic
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATLuTkee/yOyVhhEJAQLoUQ/+IIqBLLwwGjobWUSrMvgigs1qRC7VztWV
QVqILJEJchrvLpSGPgKdIzR2pTIc3SW+KiYOUhrv6/yNKXDmmQqDYgD6hGcAHjms
w4LDtXXqHNd0CVl1BcSh0KJk8aLBHKyW6K6MNiy/IuXG406POsBgG1v3n/GsmHcw
QkmXIzIZhxkDZku75TC60D/71atIGRG6IgU+biLl3LUGAvsQkOKfQAkm+WxfUtwc
N8WDb6WwGH3Jq7H5rXuZeFq+BvY6S5ZR5Vs5AjBLE+QvA5TLuGM5myxmqYtgNR6A
pXCJqRManCkIeDp4RnHMr1nnfx7msGGpIYHGJI3vYtcRFHitqNpmcaouCTsTOq4g
pBBLloMepzNV7cRaZwaANjQC5T1WVdmjWNkk9uvm3mWuyS1EYmK8yqUwUTIGjDTv
ew2VNwg/4o6MKurMuRN/ExnFfdBeJPHXiyjwfBBsKY85SbgmBjeCLocwydFE0hDR
eZJ5xS5az9mPfSEhiZqehP1mp8VXkwmQjub68yBk129Zsq9EnGrawTR+mkH/FM71
cen2Z429/LrX6BmqLCkOHyZoWSFM3G4q2X5PhTBvO/48wjTjotHWjjy/4XnumYm8
uypQIU0Yg0eHFTnAKPzBYUSuNiKtEKkQaHNZDdy8Qv5T9HmI2jtTCUf0Zt8lsEMq
ol9yTbHjE0k=
=fCtP
-----END PGP SIGNATURE-----

--=-49olpW7JNXCObFxOuBic--
