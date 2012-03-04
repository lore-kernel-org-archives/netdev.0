From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Sun, 04 Mar 2012 12:26:25 +0100
Message-ID: <4F535161.1010407@nod.at>
References: <1328400892-22409-1-git-send-email-richard@nod.at> <1328400892-22409-3-git-send-email-richard@nod.at> <20120301112732.GA6806@1984> <4F4FEC83.6090504@nod.at> <20120302164945.GA13723@1984> <4F50FAE2.4080903@nod.at> <20120304111211.GA22592@1984>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1CBE95158D84F3DBF80F4E29"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:47835 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898Ab2CDL0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 06:26:39 -0500
In-Reply-To: <20120304111211.GA22592@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1CBE95158D84F3DBF80F4E29
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 04.03.2012 12:12, schrieb Pablo Neira Ayuso:
> On Fri, Mar 02, 2012 at 05:52:50PM +0100, Richard Weinberger wrote:
>> Am 02.03.2012 17:49, schrieb Pablo Neira Ayuso:
>>> On Thu, Mar 01, 2012 at 10:39:15PM +0100, Richard Weinberger wrote:
>>>> Am 01.03.2012 12:27, schrieb Pablo Neira Ayuso:
>>>>> While merging ipt_LOG and ip6t_LOG, you introduced some bug that
>>>>> corrupts the log line. Note the extra PROTO=3D, I don't have any UD=
PLITE
>>>>> traffic here.
>>>>>
>>>>> Looks like a missing break in one switch.
>>>>
>>>> I got confused by my own logic. :-\
>>>> Does the attached patch fix the issue?
>>>> It's based on "Netfilter: xt_LOG: Add timestamp support"
>>>
>>> This patch lacks of description. If you don't make it myself, I have
>>> to do it for you :-(
>>>
>>> Please, send me patches following the standard format next time.
>>
>> It was a "does this patch solve the problem"-Patch.
>> Does it fix the problem?
>>
>> If so, I'll send an official one...
>=20
> Sorry, that's too much overhead. I don't mind testing it, but I want
> to apply it as soon as it fixes the problem ;-)
>=20

I'll try to reproduce your problem and test the fix for my own.

Thanks,
//richard


--------------enig1CBE95158D84F3DBF80F4E29
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPU1FlAAoJEN9758yqZn9e9xcH/3GvaGtO0j0pi8PfaKHIAVbX
gD1XhUDbq3OkMRqjRL12wGYS5cG/8rOTz6Bdoo9Si1bBs0hd+FSjbtexygKHbqg3
dNTzs9cFCiUYZFKU7j8c3ad6q4pF7AQ01bJIrHzXr2XafZtAWT5slQTU9jDZe3nb
GMREPJPdDbpRVNIRql/w/5kuqpWPpEm1hoppTFS726tpIFY23CorvoVqC92wDoXC
7dCcj+vmeAPnWnDOf3f8clf/i4rIGmdGBdr5A10qcfMbdj1waQbTAPukhguqAK9u
AkWtSZ3dEo7S4Xf91HVC2Eje20PWQaDstXPgXhlGkSBun+/V3TgGwpgYHp5NAn0=
=m6Bq
-----END PGP SIGNATURE-----

--------------enig1CBE95158D84F3DBF80F4E29--
