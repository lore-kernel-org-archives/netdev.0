From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC
 2988bis-02.
Date: Thu, 19 May 2011 18:55:59 +0200
Message-ID: <1456193D-84D1-46E2-B930-8FD0A5B8C409@comsys.rwth-aachen.de>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net>
 <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net>
 <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
 <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
 <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com>
 <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
 <BANLkTiku9KTHCm59cib5KY8mz0ewSLsHFQ@mail.gmail.com>
 <8C5DF277-320D-4DEB-A133-EEC301DE58DC@comsys.rwth-aachen.de>
 <ef84de89c2597793d4cca5eee446ba90@localhost>
 <BANLkTimSZEbnNVzi3UvBFndHp25S0ow7YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-15--1048038099
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tsuna <tsunanet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <BANLkTimSZEbnNVzi3UvBFndHp25S0ow7YQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-15--1048038099
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=iso-8859-1


Am 19.05.2011 um 18:40 schrieb tsuna:

> On Thu, May 19, 2011 at 1:02 AM, Hagen Paul Pfeifer <hagen@jauu.net> =
wrote:
>> So yes, it CAN be wise to choose other lower/upper bounds. But keep =
in
>> mind that we should NOT artificial limit ourself. I can image data =
center
>> scenarios where a initial RTO of <1 match perfectly.
>=20
> Yes that's exactly the point I was trying to make when talking to
> Alexander offline.  On today's Internet, RTTs are easily in the
> hundreds of ms, and initRTO is 3s, so there's 2 orders of magnitude of
> difference.  In my environment,

Exactly. This is the point. It's *your* environment. However, TCP is
general purpose. And for the wider internet 1s is know to be save. See =
the
measurements in the draft that Mark Allman run.

> if my RTT is ~2=B5s, an initRTO of 200ms
> means that there's a gap of 6 orders of magnitude (!).

Currently, initRTO is 3s. So you the gap is even larger.=20

> And yes,
> although I don't work for High Frequency Trading companies in Wall
> Street, I'm already buying switches full of line-rate 10Gb ports with
> a port-to-port latency of 500ns for L2/L3 forwarding/switching.  I
> expect this kind of network gear will quickly become prevalent in
> datacenter/backend environments.
>=20
> --=20
> Benoit "tsuna" Sigoure
> Software Engineer @ www.StumbleUpon.com

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-15--1048038099
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk3VS6AACgkQdyiq39b9uS7VNwCg/rb5DvGzmcKnWXXNJx+ikMqp
aVcAnArVGhoWtXF8Sz6DGG8aY9+UrGhm
=Jzc5
-----END PGP SIGNATURE-----

--Apple-Mail-15--1048038099--
