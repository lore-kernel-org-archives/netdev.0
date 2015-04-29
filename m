From: Mihai Moldovan <ionic@ionic.de>
Subject: Re: [PATCH] ss: Fix wrong filter behaviour
Date: Wed, 29 Apr 2015 23:22:13 +0200
Message-ID: <55414B85.1070204@ionic.de>
References: <1430227008-7440-1-git-send-email-vadim4j@gmail.com> <20150428133745.GA10292@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="XNte156wRLe9kbNabV5T4gFNjnWjVTcv9"
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from powered.by.root24.eu ([5.135.3.88]:33415 "EHLO Root24.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737AbbD2VWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 17:22:19 -0400
In-Reply-To: <20150428133745.GA10292@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XNte156wRLe9kbNabV5T4gFNjnWjVTcv9
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 28.04.2015 03:37 PM, Vadim Kochan wrote:
> On Tue, Apr 28, 2015 at 04:16:48PM +0300, Vadim Kochan wrote:
>> From: Vadim Kochan <vadim4j@gmail.com>
>>
>> Fixed applying family & socket type filters.
>> It was not possible to select UDP & UNIX sockets together.
>>
>> Now selected families are ORed.
>>
>> The problem was that filters were combined by AND.
>>
>> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>> Reported-By: Mihai Moldovan <ionic@ionic.de>
>> ---
>>  misc/ss.c | 91 ++++++++++++++++++++++++++++++++++--------------------=
---------
>>  1 file changed, 49 insertions(+), 42 deletions(-)
>>
>> diff --git a/misc/ss.c b/misc/ss.c
>> index 954a30b..46dbb39 100644
>> [...]
>=20
> Would you please respond if you received this patch ?
> I am just checking, in case if it was get into 'Spam' list.
>=20
> Regards,

I finally came around to testing this, sorry it took me so long.

Using that patch, the output looks much better. It works for my use case.=


What do we do with the "broken" versions, though? Even if that patch hits=
 4.1.0,
older versions like 4.0.0, 3.19.0 etc. will still be broken?



Mihai


--XNte156wRLe9kbNabV5T4gFNjnWjVTcv9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJVQUuFAAoJEB/WLtluJTqH4+MP/3Uogsc4LQHMsM4I/wizepHQ
yEqJ1NotyXrtij0QTQ5gCCgztdCpIj3WjKe9L1Wvw+X+BjpBjGJtGddy0sG78bbS
NMsAj0bYS6725zZ3O7XnwQzAW96BgsHecyffaB9JKFLO9C/myWG51gfrgSiWWfsS
wPQDkKKdzDMepawvs1/eco95y04jPPMurND4jRrP7Z8+phqIq0C1+NHgMsda87SJ
Q/JALPV3yX2PBV/UXHZurJMbRBISJMuEGNQt/IKjhszjHFiOg9pp7Z72gaxHM/Wd
9eK6KMp7fJ5BjTWjuQCvNbys5vyeax+Ce/yWScccBcSu1wsG/AgU8FQnZpKBxqhu
6dOXtE4qtKdAcUlQpdvclDVXYx5xtkDmokEgYcx28cdiyfeapAHxWs8r/KcNK56H
S50yxNv5BBprVQl8hMvLTdA+Ck8bKMtYesl53iHz0vMKHvghuO2AjF7vSXqP2f03
IEX1IUd3A03JeCy5uVoBxm7ZxhHKTMFqA3cpKRUNoEPVEIOI2D43HuETTydMC7WV
vFGpz5ct2H/iZtp/vjQ1zW+THCqHUaQrBUdyHfSwH/RLLGutoXWDTofSF5xEIhkv
qERAU5vubgfn5gngzo36JeThqaJaHI8/nF2xDYC/A+sc2xzs1rsuz8ry5ZV5qt47
Bz1DUhlX3BDPCgAqd6QL
=48iU
-----END PGP SIGNATURE-----

--XNte156wRLe9kbNabV5T4gFNjnWjVTcv9--
