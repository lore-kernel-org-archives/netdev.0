From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [Bugme-new] [Bug 12552] New: held lock freed in tcp
Date: Tue, 27 Jan 2009 19:57:12 +0100
Message-ID: <1233082632.4455.8.camel@johannes.local>
References: <bug-12552-10286@http.bugzilla.kernel.org/>
	 <20090127101907.89833157.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-B5FsI3HAun8+5nfj9iTN"
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47759 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237AbZA0S5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 13:57:46 -0500
In-Reply-To: <20090127101907.89833157.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-B5FsI3HAun8+5nfj9iTN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-01-27 at 10:19 -0800, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>=20
> On Tue, 27 Jan 2009 09:59:06 -0800 (PST) bugme-daemon@bugzilla.kernel.org=
 wrote:
>=20
> > http://bugzilla.kernel.org/show_bug.cgi?id=3D12552
> >=20
> >            Summary: held lock freed in tcp

> > [  598.850136] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
> > [  598.850141] [ BUG: held lock freed! ]
> > [  598.850143] -------------------------
> > [  598.850147] swapper/0 is freeing memory ffff88007a389300-ffff88007a3=
89c07,
> > with a lock still held there!
> > [  598.850151]  (&icsk->icsk_retransmit_timer){-+..}, at: [<ffffffff802=
52080>]
> > run_timer_softirq+0x110/0x290
> > [  598.850163] 1 lock held by swapper/0:
> > [  598.850165]  #0:  (&icsk->icsk_retransmit_timer){-+..}, at:
> > [<ffffffff80252080>] run_timer_softirq+0x110/0x290

Disregard, it's my own timer debugging code gone wrong.

johannes

--=-B5FsI3HAun8+5nfj9iTN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJf1kDAAoJEKVg1VMiehFYRikQAJCRCxtiDH+O6+5SqZaZmsas
wdNUKPPyBQwxjn9a8FH/h6VWwkZo7j92OZ95s4BMejvmSgtaXHFZmZSnPZMje20y
3YTSY0c5zYZqslE2Xoxcc8tgi4CTZnHGhLUCJjosdmFXXm8S8g/W8ruhVdWXl6Ih
sjatdX9ZzW1zJXjQPWW854q3fYz5tbp1Iozo5kOwWG/PUqfIdQQYoMafC+9FlxU/
qMpKdeFQvQu2JaS0PxIeY9NzGal3SUWlLOOZdTZGDCbOxgShXrn+HFiboSPsXfb8
fv4jS9UQECcpesZOy8PYBfA4UQ2fXVx0611wEOkOL18Ey+8GXiwf8W3sjPkjRIBL
M908SVaUyYvmUvXe4L4bMmDr//JbjUuTN8O+knfRSiXN6Ba22wIPpNzhJH26IwHA
665SB7vrax1BgFTNXIy1mO+KCtHJwC/trgnNLWhg+vDJBiTsYkN0Q8BIVOlndicq
fcslyRajf68NPnNyzDQ7rECKBf6WkuQy3aENZ7klngb1udOlMe31Ciov2g+tfn5K
Wtjz4UTqq0VLVb8w0dzsDDoxp1kXexHav/CAp/g3Yu32kQkXixSLs0aaIM5eM55s
5BEEhCEhNT8AzpACWBesBP06TCTMgEDgNGjDU7bFZrDTQs7av2bv6lR8jtGdQHKP
GZ5GsgtwYvVqlO47Pp3I
=T8H4
-----END PGP SIGNATURE-----

--=-B5FsI3HAun8+5nfj9iTN--

