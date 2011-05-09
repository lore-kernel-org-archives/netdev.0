From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [oss-security] Bluetooth: l2cap and rfcomm: fix 1 byte
 infoleak to userspace.
Date: Mon, 9 May 2011 18:31:32 +0400
Message-ID: <20110509143132.GA11358@albatros>
References: <BANLkTik7WyQ977-+8XapTgBrVRMyexyHKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, security@kernel.org
To: Filip Palian <s3810@pjwstk.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42495 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab1EIObh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 10:31:37 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTik7WyQ977-+8XapTgBrVRMyexyHKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, May 08, 2011 at 21:57 +0200, Filip Palian wrote:
> Structures "l2cap_conninfo" and "rfcomm_conninfo" have one padding
> byte each. This byte in "cinfo" is copied to userspace uninitialized.

Your mail client mangles the patch, it should contain original
identation tabs, not spaces.  Please see Documentation/email-clients.txt.

> patch no.1:

Don't send 2 patches as one email.  Either send 2 email or merge them
into one patch (if they are similar changes).  You'll ease maintainers'
work.

> Found by Marek Kroemeke and Filip Palian.

Please see Documentation/SubmittingPatches, chapter 12 to find out how
to sign the patch.

And please don't crosspost to oss-security and LKML - send a separate
email to o-s with a short description of a bug and a link to the LKML
thread.  LKML thread is a place to argue and discuss the solution, but
o-s subscribers are probably not interested in such a discussion.

Thanks,

--=20
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJNx/q+AAoJEBoUx9gkVaZcpjYQAJuzhv569QdU73l6oK4ROIod
bj4VO0IoKr6KtbLN4sY/+X26zoGClCzKUxy9Rrar3kqBJPvG2W5L8VzghZz1XBDu
VC8QuO5qRL8CJJc4SiUy/iLTQMcHA7HNZjiBU2EJ84qQGvxvm8TI6BKy1qAKF07T
k5hlFGz5HBPw1k2yAo6T/FBO8qLzRB8fr3fP3yulhK4qseByMNW0H2jkkWz8eXg7
dzFbEIF7TbHmBXyjSC87VT6s0XK3RRYce7RlrqTUkKSE9FTGTW1iYfDKKt6PPpPM
guP/QkU0+BI4CRcdb10Fsp5PUb+kI4VE1mh8ok7uVsbVX3VC6r/FysKvjkO59dLy
WwlbfF4VyXyVwkX8ONsukrzciTpbH/uWgDcGv91iVg7dr8sgjFSMglDw3j2KIwly
j2CiBQfc6/tIU6GAzwxyUB2S1nKQGqR6emvq5KoCsG46vPqV4CLpW3ZIY9ifOZbU
fVwzyFVFLYJvRgxSYiGrYT63YMtXetHp1WtLLl4L5QgWdlcHbMcG3O0dOXjd8Mnl
9v9r1NNtNl7Fks2/tk/TIyzKo3NnXUW79ZfvL2AscTzPd3I6uR/kXs8dNosZ0vFH
b/fGVmill8sQAQhcGbSmlbDzPn0wuds8keKoIFmvflhOif/NrpDPjC7dOZnpvSJV
5hA3C/lpdiMuZJPiKh2f
=aDZs
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
