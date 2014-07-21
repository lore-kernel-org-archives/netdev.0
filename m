From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH] skbedit: allow the user to specify bitmask for mark
Date: Mon, 21 Jul 2014 14:45:47 +0200
Message-ID: <53CD0B7B.5060308@open-mesh.com>
References: <1405931720-24383-1-git-send-email-antonio@meshcoding.com> <1405945902.10255.117.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="pmCIj1cQCWsr2JVlwxBQJ7UsHaWPwIhmQ"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev-nolb.cloudtrax.com ([54.203.245.161]:35092 "EHLO
	dev-nolb.cloudtrax.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141AbaGUMqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 08:46:12 -0400
In-Reply-To: <1405945902.10255.117.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--pmCIj1cQCWsr2JVlwxBQJ7UsHaWPwIhmQ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



On 21/07/14 14:31, Eric Dumazet wrote:
> On Mon, 2014-07-21 at 10:35 +0200, Antonio Quartulli wrote:
>> From: Antonio Quartulli <antonio@open-mesh.com>
>>
>> The user may want to use only some bits of the skb mark in
>> his skbedit rules because the remaining part might be used by
>> something else.
>>
>> Introduce the "mask" parameter to the skbedit actor in order
>> to implement such functionality.
>>
>> When the mask is specified, only those bits selected by the
>> latter are altered really changed by the actor, while the
>> rest is left untouched.
>>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
>> ---
>>  include/net/tc_act/tc_skbedit.h        |  1 +
>>  include/uapi/linux/tc_act/tc_skbedit.h |  2 ++
>>  net/sched/act_skbedit.c                | 20 +++++++++++++++++---
>>  3 files changed, 20 insertions(+), 3 deletions(-)
>=20
>=20
> You forgot to update tcf_skbedit_dump()
>=20

Oh right! Thanks Eric.
I'll send v2

--=20
Antonio Quartulli


--pmCIj1cQCWsr2JVlwxBQJ7UsHaWPwIhmQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJTzQt/AAoJEJgn97Bh2u9ehUIP/2cyYcEavmVhAQ/w+Tlp5xMM
F+NDJ4jQAM7hEvYDZnhnsWwFlGr1gCqkfBhHVvA7wekGG9bfSnORqsJgDlUHCNU0
guGe6vU/HG9uAAd0MQnwDF6fe7U4Q4wx8esuNIccdp/F0wpz2F6jP4xMBW1u9qR2
Iq7DQWnLR5UyGn9ysvatSS4HI+xABndHjOkTjzlJg+HyIrrCBxR+Q4fvDZllDOdM
5qQCXKbF/effkULBRyKaTNrRVaiy5Y8zCULlm+1Iln1TN035aI2QuAzI73VchaAc
uuDPd0mcyucx4vFSGR23ybpSvBespzhmRBHgeN5wM2t9320YSR+AbWIeEu4htM4U
CtZ6Yn5GMwR0NQ/gmccuBIeqpKqSqZdxl2CdHfNX27JVocVuDP8Moo0TglXM+fV5
JCV97rGjzLv9sikyhz7xPTInHMZ+jBYBm/8ckz45P3BdKBPSD1sHhSGgaM+/NLH/
KHE2zkMXLMRpjRif3ohKzHm3Av4vYlqwNgxAocuMnreaI7+6ZMaikO44XoUHPS42
nQ4xzscXEPN+8KuuopeSAxOu6EPzMgz4AAIy93UbPdBqDA/v5EFlSIvpR3hsie6k
13KhLfuJGIy4EA4MmFcHtk2YNG88mNeRo0fu0FXv7A6tZPIEUL4CMiy9he4FLcfA
s3JfvY0WfYDocVoNMruH
=ddn0
-----END PGP SIGNATURE-----

--pmCIj1cQCWsr2JVlwxBQJ7UsHaWPwIhmQ--
