From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [GLIBC Patch v2] inet: avoid redefinition of some structs in kernel
Date: Mon, 26 Aug 2013 01:26:04 -0400
Message-ID: <201308260126.06626.vapier@gentoo.org>
References: <1376558891-26221-1-git-send-email-amwang@redhat.com> <1376558891-26221-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart35333509.o562GfR97c";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Backlund <tmb@mageia.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Carlos O'Donell" <carlos@redhat.com>
To: libc-alpha@sourceware.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:42261 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755409Ab3HZF0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 01:26:00 -0400
In-Reply-To: <1376558891-26221-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart35333509.o562GfR97c
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 15 August 2013 05:28:11 Cong Wang wrote:
> From: Carlos O'Donell <carlos@redhat.com>
>=20
> - Synchronize linux's `include/uapi/linux/in6.h'
>   with glibc's `inet/netinet/in.h'.
> - Synchronize glibc's `inet/netinet/in.h with linux's
>   `include/uapi/linux/in6.h'.
> - Allow including the headers in either other.
> - First header included defines the structures and macros.
>=20
> Notes:
> - You want netinet/in.h to include bits/in.h as early as possible,
>   but it needs in_addr so define in_addr early.
> - You want bits/in.h included as early as possible so you can use
>   the linux specific code to define __USE_KERNEL_DEFS based on
>   the _UAPI_* macro definition and use those to cull in.h.
> - glibc was missing IPPROTO_MH, added here.

can we get something better documented here in a central location ?  having=
=20
the names laid out in a git commit message and in a few leaf headers does n=
ot=20
lend itself to being easily discoverable.
=2Dmike

--nextPart35333509.o562GfR97c
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJSGubuAAoJEEFjO5/oN/WBtwUP/AprWa3qus+KcUn0gKi8Ud/1
YW4WvJgxfJyrN9bFHdsab6uTebcuuxcxlW63Kxyi1J+X+JW6bvGXSVWE96UV7UtX
2si1HcsG4NkT2t8hQWWJ4BQ1xMRxWrgvzuRzY6EqCy8gGtM5QusUXPwuGR7p5kMg
g4+0+7nFTKWfsvHTfWf/T3tJrieLWRoo1pRjLiklENXaIHBJyit1PPgK3znE5FvV
1XhUdgUOctj/hDRc149Zd1WfUuhXoXglbLMpzg8a6iWAx5K5nRvu/ZI/rx2I1Ou0
WMKl6odQAn0FbKBSAeL+EiL6WkJWbq/7sTqq00EJ4+SJapAfyl0h8x9eWyAlSrWM
mfEARXNudE56wGsOy2W00blIRjednd6U0dE16SAX989/ajUqbv08XRxp1ecUmv3u
JCvQSG8nHjxUez5dTR5dUPUWnvHK8M7QkVsdbZlFQaw0fWTHzUH/zqL/7r4bzi9E
1p6BMZlbCItuXXEBwMvMTD39WscpHlBZwj9SsuOkeGOLVprsdKN4h29N8JYXdkfr
dJkH6fqX2yKq3mr1syi9AVCq3RHUr5/25tSfX+S5cEomVIccC+FCn1y4nUzrlYi1
Gv3bjwFwQ8KnH5ANYXo7AQcOCKcSkqlWxlhwaCTp7+nK5crKA39EyF4IYVTL46Jm
VJdxnLCOdKHv2SID7MV0
=mSra
-----END PGP SIGNATURE-----

--nextPart35333509.o562GfR97c--
