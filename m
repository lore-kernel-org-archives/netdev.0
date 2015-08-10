From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH 08/10] ss: symmetrical subhandler output extension example
Date: Mon, 10 Aug 2015 19:06:20 +0200
Message-ID: <55C8DA0C.1000000@gmx.net>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>	 <1439162006-11421-9-git-send-email-matthias.tafelmeier@gmx.net>	 <55C896BA.8040408@cogentembedded.com> <1439218395.1084.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010308040707080305050108"
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:50490 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696AbbHJRG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 13:06:56 -0400
In-Reply-To: <1439218395.1084.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010308040707080305050108
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA384


>> {} not needed. I guess you haven't run your patches thru 
>> scripts/checkpatch.pl?
>> 
> 
> Yes, although this is missing from iproute2 sources ;)
> 
> 

Thank you for reviewing so far.

I see there slipped some parts of the patch through according
checkpatch.pl for which I am responsible. I will give a V2 patch for
these asap.

Nevertheless, there are parts of the patch for which I am not liable,
so please bear with me. I only copied those over from the origin
version. Well, I am quite prepared to correct them as well in order to
come up for the "history break".


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCQAGBQJVyNoMAAoJEOAWT1uK3zQ7jOcH/3WJWNM+gcKDz/Hbj2oQLcli
M3jkIICJFZhSlCUqI0DjmVecy3ryDtxZjM4HuHcqPP8nqmdP7ykiO7p89PLTF2iC
XgA7UMMTByNJD6WSz7kjwWFlPXhvffrhE4yNZe+WkTE+HrJ8GPVydnhnr+Xo4L3g
YYDns9VWAHQgD14bd36FaoZkYmlXM1WQJZm5sgMCYWEq8ZpIHFJhqKRD6Y7e29rK
eI8BQchv30QHQiCzFOIyTqm7ncUb9CE8brBC1IFEFs9Eli5CQCoiriXANR3ntsjB
dU/6P3NuyAkis7CWILgGaKSNi0h/DPhszZQh5Gfjl4FFE5vszCVup6pM1evBWH0=
=mcKX
-----END PGP SIGNATURE-----

--------------010308040707080305050108
Content-Type: application/pgp-keys;
 name="0x8ADF343B.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x8ADF343B.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
x8nHnDFf8DVp5coDq4WJDkHBs7p71w=3D=3D
=3D67S5
-----END PGP PUBLIC KEY BLOCK-----

--------------010308040707080305050108--
