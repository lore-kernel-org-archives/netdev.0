From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 07:28:51 -0700
Message-ID: <44C77C23.7000803@redhat.com>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru> <20060726100431.GA7518@infradead.org> <20060726101919.GB2715@2ka.mipt.ru> <20060726103001.GA10139@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE0F541614E1AF69A90F7C149"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751636AbWGZO1h@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
In-Reply-To: <20060726103001.GA10139@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE0F541614E1AF69A90F7C149
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Christoph Hellwig wrote:
>> My personal opinion on existing AIO is that it is not the right design=
=2E
>> Benjamin LaHaise agree with me (if I understood him right),
>=20
> I completely agree with that aswell.

I agree, too, but the current code is not the last of the line.  Suparna
has a st of patches which make the current kernel aio code work much
better and especially make it really usable to implement POSIX AIO.

In Ottawa we were talking about submitting it and Suparna will.  We just
thought about a little longer timeframe.  I guess it could be
accelerated since he mostly has the patch done.  But I don't know her
schedule.

Important here is, don't base any decision on the current aio
implementation.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enigE0F541614E1AF69A90F7C149
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFEx3wj2ijCOnn/RHQRAlJEAKCohm3ngAyWs0Jo5O16Urun9K9lsgCfcymV
jsPinmGcEThS5CJG75Qh00Q=
=phCc
-----END PGP SIGNATURE-----

--------------enigE0F541614E1AF69A90F7C149--
