From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC
 2988bis-02.
Date: Thu, 19 May 2011 08:10:40 +0200
Message-ID: <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net>
 <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net>
 <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-33-1060726600
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hagen@jauu.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsuna <tsunanet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-33-1060726600
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

Hi,

Am 19.05.2011 um 06:33 schrieb tsuna:

> Presumably if the user decides to tweak these knobs, they'll know
> what's appropriate for their environment.

Are you sure? I'm not. I fully agree with David that minRTO is
something that a user shout not control at all

> Or are you suggesting that
> one value be derived from the other?  (e.g. tcp_initial_fallback_rto =
> 3 * tcp_initial_rto)
> 
>> As a result of all of this, I do not really think this is something
>> the user should control at all.
>> 
>> I really would rather see the initial RTO be static and be set to 1
>> with fallback RTO of 3.
> 
> I can also provide a simple patch for this if you want to start from
> there.  And then maybe we can discuss having a runtime knob some more
> :-)
> 
> -- 
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


--Apple-Mail-33-1060726600
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk3UtGEACgkQdyiq39b9uS5BAQCg8rVcWTflWjYU7QI7/dqL2ceV
Bm8AoIKqyDcY2osrORNtI3LGQN7D0+zz
=8ujM
-----END PGP SIGNATURE-----

--Apple-Mail-33-1060726600--
