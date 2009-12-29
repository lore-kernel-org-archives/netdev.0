From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
Date: Tue, 29 Dec 2009 01:29:31 +0000
Message-ID: <20091229012931.GW2721@decadent.org.uk>
References: <20091228194834.GA18422@hmsreliant.think-freely.org> <20091228195053.GB18422@hmsreliant.think-freely.org> <20091228213114.GA24285@zoreil.com> <20091229005152.GV2721@decadent.org.uk> <20091229011608.GC7037@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="lR6P3/j+HGelbRkf"
Cc: =?iso-8859-1?Q?Fran=E7ois?= romieu <romieu@zoreil.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, nhorman@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60103 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750988AbZL2B3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 20:29:38 -0500
Content-Disposition: inline
In-Reply-To: <20091229011608.GC7037@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lR6P3/j+HGelbRkf
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-12-28 at 20:16 -0500, Neil Horman wrote:
> On Tue, Dec 29, 2009 at 12:51:52AM +0000, Ben Hutchings wrote:
> > On Mon, 2009-12-28 at 22:31 +0100, Fran=E7ois romieu wrote:
> > > (I'm back)
> > >=20
> > > The Mon, Dec 28, 2009 at 02:50:53PM -0500, Neil Horman wrote :
> > > [...]
> > > > frames were received on NIC's supported by this driver.  This was m=
entioned in a
> > > > security conference recently:
> > > > http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> > >=20
> > > Is there a paper ?
> > [...]
> >=20
> > I was present in the session and emailed you and Neil about this
> > yesterday; did you not get the message?  The slides are now linked from
> > the above page; see pages 74-87.  I suggest you ask the speaker if you
> > need any more details.
> >=20
> > Ben.
> >=20
> I'm sorry, Ben, I don't think I received this note (although I admit I've=
 not
> been checking to closely over the holidays).  I jumped on this after I go=
t a
> phone call about it today.  I'll make sure to look for your note shortly.

My memory failed me - I actually sent this to Francois and Eric:

> Hopefully you're already aware of this, but I'm not sure.
>=20
> Fabian Yamaguchi made a presentation at 26C3
> <http://events.ccc.de/congress/2009/Fahrplan/events/3596.en.html> which
> included a bug in r8169 reintroduced by:
>=20
> commit fdd7b4c3302c93f6833e338903ea77245eb510b4
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Tue Jun 9 04:01:02 2009 -0700
>=20
>     r8169: fix crash when large packets are received
>=20
> On some older r8169 controllers this will enable scattering on receive,
> and the first word of the second and subsequent RX buffers for a frame
> will wrongly be treated as a status word.  This can be used for denial
> of service at the very least.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.

--lR6P3/j+HGelbRkf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIVAwUBSzlbeOe/yOyVhhEJAQrPThAAy8gCWHnGU3glMX50VecWFdfZGUgfM30Q
gggTwIe5jsYzg3nQgnzX3NnmJeqCAgzJhD/o+ghagN3evF3wSrPDDH3thD1sHypP
bh3Y4VPS8MS3YcpJuC/ZTFYjxx17fe7M+NKlkVv1blHoTefu03ffsIxZxO+mj3ga
CMHynBKLqziqKdJ/vtqqsafqKcCcSd8GDhoDYHbAUnANBV6iDO8ULNA1f2zZpB15
atQ/Gjfw4boR1fUpZFvAxelShh6W7XYImJq8WogvRjYCIAJzKfbwjurAYpLMegGm
r21W7B9KvWbMS/h1oJIqRdZh6ksIxRMbio4bCYGmbcl4A/jbumYn8G1/EHm4sJkF
3nJTf/kglFxR5KDKp4qdrNEZIqTLqpkKc8GExUW1gvQ3E509XqbEDzKEETAZvKf0
qxg7cOEz5+AnriyITe6/0LgygpKFg0bMP4l+vm8P/f5WouYze0sxydO3FHkR+h/4
5lO61Yp7ycmOFhGuIbEGIr5jXpVNdt0o+kluHR0x/R+RhtUgI3LhTLY0z66Zczdm
VZZn4Cm/MommrlBDFi60ucQRPa+vmNh2X7HFPxQbZb2cOTtPC8wfP+lcIdDWfqPU
RsjJfJP5qd1B+YepuTVHTlbYCqq0E8uO106Py5j9OL+/oGXIU+hwvQM+9oMNY5fd
stXUJKKSn0k=
=yOrB
-----END PGP SIGNATURE-----

--lR6P3/j+HGelbRkf--
