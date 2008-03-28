From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 22:43:01 +0100
Message-ID: <1206740581.22530.83.camel@johannes.berg>
References: <47ED3F1A.1090101@linux.intel.com>
	 <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
	 <alpine.LFD.1.00.0803281329340.14670@woody.linux-foundation.org>
	 (sfid-20080328_205203_254278_BF9EB41F) <1206738071.22530.80.camel@johannes.berg>
	 <alpine.LFD.1.00.0803281418570.14670@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GYpE09vFxvPHorkaTNUV"
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, Dmitry Torokhov <dtor@mail.ru>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758803AbYC1Vnq@vger.kernel.org>
In-Reply-To: <alpine.LFD.1.00.0803281418570.14670@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GYpE09vFxvPHorkaTNUV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > That I've seen before, analysed a bit and posted:
> > http://permalink.gmane.org/gmane.linux.kernel.input/4281
>=20
> Ahh.. And this is presumably triggered either by some new Xorg behavior i=
n=20
> fc9 or just the scheduler timing changes that caused other things too?

I tend to think it's actually a regression, I've done exactly what I
described there dozens of times before on older kernels and it doesn't
seem to be a race condition, X always locks the input device and I never
had trouble with that before.

> Your suggested solution sounds ok, but I'm also wondering why those thing=
s=20
> aren't properly refcounted? It does sound like a bug to free the thing=20
> before all users are gone - regardless of anything else. Hmm?

I have to admit to not understanding the depths of the input code, I
just took a quick look when I posted that. Mind you, that was 5 weeks
ago!

> But the ungrab sounds like the best short-term fix. Do we have a patch fo=
r=20
> testing? Please? It's pretty late in the 2.6.25 cycle for these kinds of=20
> things..

I don't. I think Dmitry just said in the other mail that he did, but I
haven't seen that yet.

johannes

--=-GYpE09vFxvPHorkaTNUV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+1mY6Vg1VMiehFYAQKA/xAAnzeRiNaOKiz7fMNUddmZJIB4NINYPAv5
hDKgJCnHSxSGZD5ierB0B/e8HNjH5mZ50VKK9mzsVk5EzBqDt4lo+3WRyYW+ZgXl
D647jkeaVFp9Mi5F2xzdMSEIm2CeERTgCTN4IdaLa+ze1Z3Vce0R0nmunsT+KNRI
R8tYDvp7SPEU+s834IcS6HgVtz9nkYHXMEk2tEs6pUz9suXCa8bHKWcVxr8Y+FcV
rk6tv+4/0ZDPW5M9bmrlp44CeSu2J2LBPWp5IejVf1DuUizqRLa4DCCS3HXujJOC
syE7fG4kPYllKwr+lwI0ntP98q6tl6HAUv80hoPWMvEE5pkUawOFAxJW0HQ4BbUv
Xlza7Y3zDOMszv13R4c/yuORlS0BxEyNmtoMhJY5wegcNnOkjMrhWlOwy1M+p89r
zITZFwkdgCR0oSHb66Kbma0k1TD5eZTEwG2vWD5BKLcsRBshAqtgk/LnkE2KwXLk
czyla/ZRga2hB9nAVRJQOTruNezbZmz9u8d3UwYiuYPjtrOGtFec0GywUyv+V3ZI
0Ll3Y6Fp8sA5nUTAyyeo+spesvJDsNzL2+1IbbGaNvbiuf+v4+/daAotZ6OjG99n
/hpuWL4b3wPwvAemJbFDQJ3cZ1iyqzB6g5RsY4JoFr8C4pYLmM+iYML98Wtu8ICf
KHJKUv+iCt0=
=YsuD
-----END PGP SIGNATURE-----

--=-GYpE09vFxvPHorkaTNUV--
