From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Sun, 28 Mar 2010 00:47:25 +0000
Message-ID: <1269737245.8653.162.camel@localhost>
References: <4BAE6C92.2060801@iki.fi>
	 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
	 <1269732054.8653.155.camel@localhost>
	 <20100327.163005.28815553.davem@davemloft.net>
	 <20100328003143.GA8501@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-gDAx3wc8MozDJGuDfE8d"
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	ivecera@redhat.com, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33452 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754422Ab0C1Arc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 20:47:32 -0400
In-Reply-To: <20100328003143.GA8501@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gDAx3wc8MozDJGuDfE8d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2010-03-28 at 02:31 +0100, Fran=C3=A7ois Romieu wrote:
> This is quite similar to b39fe41f481d20c201012e4483e76c203802dda7
> though said registers are not even documented as 64-bit registers
> - as opposed to the initial TxDescStartAddress ones - but as single
> bytes which must be combined into 32 bits at the MMIO read/write
> level before being merged into a 64 bit logical entity.
[...]

Thanks Fran=C3=A7ois.  Which hardware have you tested this on so far?  I wa=
s
hesitant to make changes because of the huge number of variants.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-gDAx3wc8MozDJGuDfE8d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS66nGOe/yOyVhhEJAQJ5OxAAwhRsJjduUKdrXIWlYkU8SQ4NRTEVtyHK
jdxrRHVRQdgd/dxpiQwvVssIecCKIlopfSb7iPrs+D3qQiT8Oltm/r8yg/tGHOzI
U0vwcBO2ay2ZATly3uMcxRwjwVdmNZsSoOTqzQAft6xSd57xlK9XJsU4EmZ84Jn4
36l963ap4wWimwcQKinUHaesB3KW0Y1jvM5Avk0w70EtKiWIdYyIn7gXTqgSra18
FF/B5VmCwmIRtFIUftJGsNqqZxPVpWeztqSO40yngtVCXJ/wiMT14S2BCb/vOaPw
V8bkBnuuAyJ0mzhcK+UqLUVbhA6fQOYf2LKqcTTHQngIudCRSdeZrLQ7fE2I5/Mk
cse3gNyJA0CJFA1UIb/OPae4fxUSE7szyD2Latu5xiqv4GE6HGQmtaIGv02EybUZ
bc68eeEvjk+uV/ayY06g/04dGrW3j2fQvhqlUoFaaqY8Qn1h59NPCV63VF8vgnP3
eBDodjEkI7PNXdNbqNKweuA1RVfp1dZmXIJpqKcJ16t0TBMArBIDqAFeaTkt4zHW
jcvf/4R4x67r8816nsDKYdCK6jmAPg1vm8m2fqEZeGcqPDuyZsKdziTDaSY5goVB
+pVAoZO6BjztOit+Qa5SolYq+wlvAy9yEZGFp28O5JBb3OAvBk1VPrlRofluzQ/X
mOsg9DduZTk=
=NuVw
-----END PGP SIGNATURE-----

--=-gDAx3wc8MozDJGuDfE8d--
