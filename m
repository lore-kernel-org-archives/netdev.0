From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH 03/10] batman-adv: Make DAT capability
 changes atomic
Date: Fri, 14 Aug 2015 22:49:03 +0200
Message-ID: <55CE543F.1040507@meshcoding.com>
References: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
 <1439310948-32426-4-git-send-email-antonio@meshcoding.com>
 <55CA4ED2.9070207@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="kQ9ve6Ta7MphAO311GseuLWkaBxBHSxUa"
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Marek Lindner <mareklindner@neomailbox.ch>
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:11096 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbbHNUtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 16:49:21 -0400
In-Reply-To: <55CA4ED2.9070207@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kQ9ve6Ta7MphAO311GseuLWkaBxBHSxUa
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 11/08/15 21:36, Sergei Shtylyov wrote:
>>       /* check if orig node candidate is running DAT */
>> -    if (!(candidate->capabilities & BATADV_ORIG_CAPA_HAS_DAT))
>> +    if (!(test_bit(BATADV_ORIG_CAPA_HAS_DAT, &candidate->capabilities=
)))
>=20
>    () around the tst_bit() call not needed.

Thanks for the hint Sergei. Even if I don't remember having seen any
complaint from checkpatch.pl about this.

I'll resend the pull request with this fixed patches.

Cheers,


--=20
Antonio Quartulli


--kQ9ve6Ta7MphAO311GseuLWkaBxBHSxUa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVzlRDAAoJEOb/4TMchkvflXUQAJQNP6eSYmtjrT1JKZP3Mq/L
5jN7e2/isNccOxUeFKIfPiM0KFTb+gt2nlr7dx2V1l9R4SITVqWpuDR2wSwu3Imj
75MpHxir5K7IEaWJcTqK2UpahEOHR+elBLhb0//VfAIopOBpJ1ZUv00m54Xa8Pq7
+7YR3vp29OgkZb0U2STxVeN0PF6wAp7mWqJyfDlaUysSGOhJsWwJE0vk1eAHnpyE
sCOdcCAYJSF/6WtiN1e7ybCBb78kf2Lv1wj/nZind8nn4KkaVt0NCEqdrTJANGsa
VURIeEe8bsliwYBKO3JUIe2kEhHydwSwL9VLrrRFAt57OeWZHeAD/f+mIUZvcNZn
Mh4V5WCCSCC3lcdHTWgMBAkJ3bFGHPvqo5+xV9P72YtmYkRyGEQBq0nFn3s0mFhF
dOgyhHmXV4y1b1kDb/9EoMGvpkzPL0R/VU5f+CWQj088/awCcOUvCQM7VD4Il5aO
iTS2kyB+zgi8cOKpQlCGT4m11kT6P88XYtCV2cu+KBovL5dxVcmgssxRSCNQpbe6
dWNXgp5gD5zOVYyFOvOc8etPGhHAHxa5oOXO9sh8NABU2dakNR1ibJaKnR2F57Gi
JNOKZOCfhpmx+BHUK5zzTVMg7KJSxOD37VeTcbVfejdSbQRO26clAfOyPxaTSd+p
f1Mx8yf4DiJFXMqG/WJr
=IzXs
-----END PGP SIGNATURE-----

--kQ9ve6Ta7MphAO311GseuLWkaBxBHSxUa--
