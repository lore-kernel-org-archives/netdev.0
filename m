From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: Kill I4L?
Date: Mon, 09 Feb 2015 11:53:52 +0100
Message-ID: <54D891C0.2010303@imap.cc>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>	<1423328797-17865-3-git-send-email-baspeters93@gmail.com>	<54D650BF.5000400@cogentembedded.com>	<1423336761.2933.7.camel@perches.com>	<1423341800.2246.68.camel@x220>	<54D7BD4A.4090101@imap.cc>	<54D7F87E.4050506@linux-pingi.de> <CAOgR63f702_QTHpnAB-G9-o3DPEuyiESLeNTz4saOTHB4SnBdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Bolle <pebolle@tiscali.nl>, Joe Perches <joe@perches.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"isdn@linux-pingi.de" <isdn@linux-pingi.de>,
	Julia Lawall <julia.lawall@lip6.fr>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>,
	Karsten Keil <kkeil@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOgR63f702_QTHpnAB-G9-o3DPEuyiESLeNTz4saOTHB4SnBdg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 09.02.2015 um 11:07 schrieb Bas Peters:
> 2015-02-09 0:59 GMT+01:00 Karsten Keil <kkeil@linux-pingi.de>:
>> Am 08.02.2015 um 20:47 schrieb Tilman Schmidt:
>>> Am 07.02.2015 um 21:43 schrieb Paul Bolle:

>>>> [M]aybe we should consider, say, removing i4l and pre i4l and
>>>> see who complains. That might be a rude thing to do. So
>>>> perhaps the various ISDN flavors should be left alone until
>>>> ... what exactly?
>>>=20
>>> I'd support that step. I don't think it'll hurt anyone because
>>> the cards supported by i4l are mostly ISA cards anyway. The
>>> only exceptions are the HiSax family which is now supported by
>>> mISDN, and the Hypercope family which is supported by CAPI.
[...]
>>=20
>> But I4L is still the default in some Distros, so we should allow
>> a warning period. But again, I'm fine with this to do it.
>=20
> Is there any explicit reason why 'dead' drivers that might still
> have some users ought to be removed?

The reason is the maintenance load it produces. There's a continuous,
annoying trickle of patch  proposals, discussions, conflicts with
development in other, still actively maintained areas of the kernel,
and so on. The present discussion being a point in case.

> Does it hurt anyone to leave the code in there, despite it barely=20
> being used?

Yes it does. Not much, but the pain is increasing over the years.
Every time someone tries to touch that code there's the problem
that no one can actually answer for it, much less test anything.
Theoretically a patch for a driver should not be accepted without
testing it on the actual hardware, but in the isdn tree that rule
has long been abandoned because nobody has the hardware and can do
the test. Consequently it isn't even clear whether all of it still
actually works.
It also hurts the few remaining Linux ISDN developers, distros and
users that Linux ISDN support is so fragmented. For example, the
Gigaset ISDN driver which I maintain can be built with either CAPI
or I4L support, so each time I touch it I have to build and test
two variants.

> We're not talking about a particularly huge driver here, either.

But one that's particularly difficult to maintain, without
providing any noticeable benefit in return.

- --=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJU2JHAAAoJEFPuqx0v+F+qn5EH/0iXrzTWChbu/0W8nDz4/qtC
=46WQYbeIxTutzsEtVAhOYM7mz+9mqgaqNkVpmrz4lLg3FY4q2kzG1GjSihqP0GsT+
rLWJ+7gTnNxjNOk6OOZo+GaOjcvtVAro/2N5NXhHxTseumbH4I371a2rw0HBls97
iCPB2g6mJvNnsLjb612qcgsGahxMWVE/3q+6O1IKujPCTNQsJNaeqQMPT3YFJwq+
4YMs55RpVbpP5GPdRsaW/Zkwx8Se/4cK1MFaqX9xEePgZDUYMCPT2BPEa7E3yUwF
kjJU5LnBTKAjI8IzXDPTzznAyrMnH6IAjtJSmwpnyNintv2dtCK0VPhjhh0TA/M=3D
=3Dd5Or
-----END PGP SIGNATURE-----
