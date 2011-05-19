From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC
 2988bis-02.
Date: Thu, 19 May 2011 08:36:09 +0200
Message-ID: <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net>
 <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net>
 <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
 <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
 <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-34-1062255599
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hagen@jauu.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsuna <tsunanet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-34-1062255599
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii


Am 19.05.2011 um 08:25 schrieb tsuna:

> On Wed, May 18, 2011 at 11:10 PM, Alexander Zimmermann
> <alexander.zimmermann@comsys.rwth-aachen.de> wrote:
>> Am 19.05.2011 um 06:33 schrieb tsuna:
>>> Presumably if the user decides to tweak these knobs, they'll know
>>> what's appropriate for their environment.
>> 
>> Are you sure? I'm not. I fully agree with David that minRTO is
> 
> s/minRTO/initRTO/, right?

Yes of course :-)

> 
>> something that a user shout not control at all
> 
> I personally don't like to hold the hand and spoon feed users too
> much, I want to trust them to be responsible and know what they're
> doing.  Yes, there will always be people who will act stupid and do
> stupid things with whatever knobs you expose.  The web is full of
> people who advise to tune up all the TCP rmem/wmem parameters to crazy
> high level based on the voodoo belief that they're going to improve
> their TCP performance, but then as long as you have knobs in your
> system, these people will misuse them anyway and shoot themselves in
> the foot, what can we do about that.

But if you tune rmen/wmen to crazy level, it's only your TCP performance
that hurts (and maybe the receiver's one).

If you set the initRTO=0.1s, it's good for me but bad for the rest of the
world. That's the difference.

Or do you want to implement a lower barrier of 1sec so that you can ensure
that nobody set the initRTO lower than 1s? 


> 
> There's also a good chunk of people who know what they're doing, and
> for them compile-time constants are annoying because it's inconvenient
> to experiment and iterate quickly when you need to recompile your
> kernel to change a value.  If turning the compile time constant into a
> knob leaves the code reasonably straightforward and doesn't incur too
> much overhead, then why not do it?
> 
> Regarding this knob in particular, I can imagine that people who are
> in environment where RTT easily gets around 1s will be upset by the
> change in the default value, and doubly upset that they have to
> recompile their kernel to change the value back to 3s.  I'm in favor
> of the reduction of initRTO, for the same reason Google is, but I can
> also understand that the direction we're taking might not be
> appropriate for everyone.
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


--Apple-Mail-34-1062255599
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk3UuloACgkQdyiq39b9uS4u+QCgkTNKQJta2KV8HJvVM95Q0/vH
rNAAoIa+QlC5gNgk5T9b1K2VsE5LT12S
=fMU8
-----END PGP SIGNATURE-----

--Apple-Mail-34-1062255599--
