From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 10:50:48 -0300
Message-ID: <20130219105048.198e2cfd@redhat.com>
References: <20130219070310.2cadad7a@redhat.com>
	<20130219101121.GJ23197@arwen.pp.htv.fi>
	<20130219081149.46972f56@redhat.com>
	<20130219114345.GA26623@pd.tnic>
	<20130219091610.2b746a30@redhat.com>
	<20130219123502.GD26623@pd.tnic>
	<20130219094640.2abf1a66@redhat.com>
	<20130219130626.GE26623@pd.tnic>
	<20130219131500.GW23197@arwen.pp.htv.fi>
	<20130219132853.GG26623@pd.tnic>
	<20130219133809.GA4390@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/pgfTfKshO5Qr646IuP6JbkD"; protocol="application/pgp-signature"
Cc: Borislav Petkov <bp@alien8.de>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
To: <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130219133809.GA4390@arwen.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/pgfTfKshO5Qr646IuP6JbkD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Em Tue, 19 Feb 2013 15:38:09 +0200
Felipe Balbi <balbi@ti.com> escreveu:

> Hi,
>=20
> On Tue, Feb 19, 2013 at 02:28:54PM +0100, Borislav Petkov wrote:
> > On Tue, Feb 19, 2013 at 03:15:00PM +0200, Felipe Balbi wrote:
> > > what's the problem with that ?
> >=20
> > Not a problem - simply annoying.
> >=20
> > $ ./test.sh
> > cat: /path/to/file/that/doesnt/exist.txt: No such file or directory
> > Setting scrubrate to:
> >=20
> > I'm sure someone would ask themselves why all of a sudden the file is
> > gone.
> >=20
> > > $ cat /path/to/file/that/doesnt/exist.txt
> > > cat: /path/to/file/that/doesnt/exist.txt: No such file or directory
> > >=20
> > > Didn't see any gates to hell opening here...
> >=20
> > And I don't see why we have to debate such a trivial thing when we can
> > fix it *properly* without *absolutely* *not* upsetting userspace.
>=20
> because changing the permission will cause the same issue:

It is actually worse, as if someone is using a C code to open the device
with
	fp =3D open ("/sys/devices/system/edac/mc/mc0/sdram_scrub_rate", O_RDWR);

It will now start to fail if the device doesn't have both permissions.

Regards,
Mauro

--Sig_/pgfTfKshO5Qr646IuP6JbkD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRI4M4AAoJEGO08Bl/PELnlxIP/iswJpmUNx1BT0huCaRU+Szu
SqiMW60BD7Fz6CXg/fMzBuXeyECYOY6xf9IeJziuQ9pxqtDhfm9QwSKyog+tcsom
c3WG1iZdT9G7wYVuo4Hf9Ko5kl9KnWWwLxrHCbwzYoW8qDXbKJRHNkmr3IgoXaql
1cutrO7GEck78LxB6lPmbLqr+oS5wlrn0Xzq4CGKg9Rv0o/YUvIx1gaX9U9DxGN/
TJhbi0HJpcdnTjD8bKw/I1weBt188oM/C7zXopM9yOxEs7V1yNx3yEvs91ZfWoXa
ZVbTtJYOuTeEC9A5QSo8iU6PNy0pU1QDTBVO8t6lf64VCA8Nh/N9oyklY0ouVFye
AeiKXpfftpTwTYwFCSP9j5V05irCJbTe7/QuXdsY6mcJGppp7ugZsXijk2XklEUx
h32omPW7ObZQCALPjd5JwrGuSmX9NwR0kSado6zJv10mGkasvAk2D+WWlR9F5jmT
11OY5zGJc79SU83UWRjmJSPH4m7uSgBYb0JapgAc6rzWZ1HDyHjEYZeboQPFhgS/
FtJukO6dU5VKoA33muqDKgVYjDBw1zgGMmgZpd+Wh03Mjyy1l09XotitWno3POTy
eTWXoPJuyfzq5uiQerv24eoKKTpCxkdIlUH90Q9tFaO4VFpgjwYMCYHzwFAsG66C
iHO+MA/mSqjn6fHp0DUR
=qwnw
-----END PGP SIGNATURE-----

--Sig_/pgfTfKshO5Qr646IuP6JbkD--
