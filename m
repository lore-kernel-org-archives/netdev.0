From: Steven Haigh <netwiz@crc.id.au>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Fri, 16 May 2014 12:13:45 +1000
Message-ID: <53757459.4030107@crc.id.au>
References: <395225650.20140430124506@eikelenboom.it>	<536162D3.5080307@citrix.com>	<94755525.20140501002553@eikelenboom.it>	<53624E25.8040404@citrix.com>	<1810270947.20140501155911@eikelenboom.it>	<53626C39.3030304@citrix.com>	<928229683.20140501193936@eikelenboom.it>	<198418193.20140501213951@eikelenboom.it>	<5363A508.1000602@citrix.com>	<653156457.20140502160632@eikelenboom.it>	<5363AFED.5080601@citrix.com>	<1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com>	<5363B929.1000502@citrix.com>	<35970097.20140502182818@eikelenboom.it>	<5363CBB0.6050804@citrix.com>	<15602339.20140505121912@eikelenboom.it>	<536916E9.7010509@crc.id.au>	<53691848.5010809@citrix.com>	<437888929.20140506193723@eikelenboom.it>	<536924DC.9080606@crc.id.au> <5369EBF9.20304@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="2GERVc1LbwsbrhbO7AALJOwe2lFqwGwUh"
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.crc.id.au ([203.56.246.92]:37105 "EHLO mail.crc.id.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233AbaEPCNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 22:13:45 -0400
In-Reply-To: <5369EBF9.20304@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2GERVc1LbwsbrhbO7AALJOwe2lFqwGwUh
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 07/05/14 18:16, David Vrabel wrote:
> On 06/05/14 19:07, Steven Haigh wrote:
>> Well, I'm trying to get a test together - although I don't have webdav=

>> anywhere... I was going to try it via FTP, however I'm hitting another=

>> MM bug in Xen:
>> 	https://bugs.archlinux.org/task/38596
>>
>> This references:
>> 	https://lkml.org/lkml/2014/1/23/596
>>
>> It says that should be fixed in 3.15-rc3 (if I understand properly) -
>> but I'm also hitting that on 3.14.2. Did these changes get ported back=

>> to the 3.14 tree?
>=20
> This is fixed by 29c7787075 (mm: use paravirt friendly ops for NUMA
> hinting ptes) which is tagged for stable but hasn't yet been picked up
> for 3.14.y.
>=20
> You can also work around it by disabling CONFIG_NUMA_BALANCING which
> doesn't work with Xen PV guests anyway.

Hi David,

Just wondering if there has been any movement in getting this into
3.14.y. I see we've now just hit 3.14.4 with no mention of the patch for
issue.

--=20
Steven Haigh

Email: netwiz@crc.id.au
Web: http://www.crc.id.au
Phone: (03) 9001 6090 - 0412 935 897
Fax: (03) 8338 0299


--2GERVc1LbwsbrhbO7AALJOwe2lFqwGwUh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTdXRZAAoJEEGvNdV6fTHcevUQAIdbZIJEO9uTzyo3atzrbIr4
1ZUPd4v3tikhYVdGXkNiM6tPUytXNh0W+A2US4Ovu0YdJj6L4tlS61rudpAz62b1
xen45jDqktc0iw3iGPlPf3oeHqPQej4n6lBdbiX8UX2r8bJawYmt5G72+7kXYkFK
VQnLu96MfECveFyFAnTzhCwF1X9sJE1C4AfKZeTyfs0ZwGAfe/ve26gVUK9vYwuk
gaX1R5fXSymFFl6/w1x4ytoMyiKvSBT993kCZxpfqIABB1QTq/odKkbK2mvl3Zxx
LvzYUX0IGFpXE8ywgw1yNkT7H9rrWIvXs/WZi9Jq8TmWdhz2zMRwW0R+ifsbfi8J
5n/B8Wvgy+cE0sEYJeKdW2rf5QtZltt6L8eFdWiQr/0XpcRYu7oVebvuLyvJefvb
KT98i0xprQWQ0A4nPdCGNUnwNkXIFyLqUOdoDOLwGQB0DmBlveFHPqBvR4CzFSLY
6iMMhzo+mO1+tz13oV0QXDSTh4+/HlmpCwKCaQv6+Xvm+wPM92EyYrwcu61D054p
ROclU+6AyuRysX6nx3UCqBTamNHUb2fXUcSco6HT0zUnNrgTAK8UwUQ01VK959gN
6z77oURQ0oloxEBSDsxXqGFEJBVGaVP84U17tFa2nnMQDSiNRIbhDR7nRnPwC8Jl
mK391E9DwY/TZvqcPHBw
=VMhn
-----END PGP SIGNATURE-----

--2GERVc1LbwsbrhbO7AALJOwe2lFqwGwUh--
