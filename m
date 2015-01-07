From: Cosmin GIRADU <cosmin.giradu@rcs-rds.ro>
Subject: Re: [PATCH net-next] net: sched: use pinned timers
Date: Wed, 07 Jan 2015 12:06:59 +0200
Message-ID: <54AD0543.1090806@rcs-rds.ro>
References: <1411261290.26859.103.camel@edumazet-glaptop2.roam.corp.google.com> <20140926.002710.1595423408687413602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="fv8QCOAhQbXDdq86fOPAJV4sxOTpoXUha"
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy2.rcs-rds.ro ([212.54.127.5]:54288 "EHLO
	mailproxy2.rcs-rds.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbbAGKNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 05:13:00 -0500
In-Reply-To: <20140926.002710.1595423408687413602.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fv8QCOAhQbXDdq86fOPAJV4sxOTpoXUha
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 26/09/14 07:27, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 20 Sep 2014 18:01:30 -0700
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> While using a MQ + NETEM setup, I had confirmation that the default
>> timer migration ( /proc/sys/kernel/timer_migration ) is killing us.
>>
>> Installing this on a receiver side of a TCP_STREAM test, (NIC has 8 TX=

>> queues) :
>  ...
>> Current Qdiscs that benefit from this change are :
>>
>> 	netem, cbq, fq, hfsc, tbf, htb.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Looks great, applied, thanks Eric.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Hi Eric,

    I saw that this patch didn't make it's way into the stable branches.
So I have two questions:
        - Would it be safe to apply to linux-3.12.x stable?
        - If yes, would there be any [noticeable] efects on a [pretty
complex] HTB setup? (I know, test and I'll see,
           but if theory sais I won't, then there would be no point to
the test, would there?)

Thank you!

--=20

Cosmin GIRADU
OSS Engineer
RCS & RDS - Unified Services
Phone:  +40-31-400-6323
Mobile: +40-77-020-0858
http://www.rcs-rds.ro

=2E......................................................................=
=2E..
Privileged/Confidential Information may be contained in this message. If
you are not the addressee indicated in this message (or responsible for
delivery of the message to such person), you may not copy or deliver
this message to anyone. In such a case, you should destroy this message
and kindly notify the sender by reply e-mail.



--fv8QCOAhQbXDdq86fOPAJV4sxOTpoXUha
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUrQVDAAoJEKIzlqmspKc9K5UH/1sTkNszwXS0fLB34p+cgLkS
9WoM7mfkKUJiUQuH18soaChymoy1ecjYPqBiWYifl+DM8zcMJw1CVL5JlUz1zE+n
iaW24lVOBUAKZw5z82zf4XhlJUd9qN/k1tAYUvUHfrL9HwtTIkQDrLnGW9q2Lw1O
y3Kia89bgwlUJXYETBINjvPAIujQldEx8wGVtB9cC3UjBMIKsgYW6a6+/q1+8GE0
PcXuNtyIfzJjICNz8lh5fBFaB+7UUoR1dScMtDWoEkERvnkIMnNoCNgW3XyvVnDP
tysHoBeGS6Cm8OIKk1+VuR8hw/U994kMUntfEQdxv6XP8pQOyvogYqq07phpPZw=
=RKSn
-----END PGP SIGNATURE-----

--fv8QCOAhQbXDdq86fOPAJV4sxOTpoXUha--
