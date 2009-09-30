From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 17:21:17 +0200
Message-ID: <1254324077.3959.7.camel@johannes.local>
References: <200909111648.50902.mb@bu3sch.de>
	 <87ocosqykb.fsf@purkki.valot.fi> <1254322466.3959.5.camel@johannes.local>
	 <200909301710.31082.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-yurZqWm/P6lWkQy5ETrt"
Cc: Kalle Valo <kalle.valo@iki.fi>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58889 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbZI3PVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 11:21:33 -0400
In-Reply-To: <200909301710.31082.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yurZqWm/P6lWkQy5ETrt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-09-30 at 17:10 +0200, Michael Buesch wrote:
> On Wednesday 30 September 2009 16:54:26 Johannes Berg wrote:
> > On Wed, 2009-09-30 at 17:47 +0300, Kalle Valo wrote:
> >=20
> > > I agree with Michael. The bug is real and I have verified that
> > > Michael's patch fixes the issue. Better to apply the patch now, it's
> > > trivial to change the implementation if/when the network stack has
> > > support for this.
> >=20
> > FWIW, I think in mac80211 the in_interrupt() check can never return tru=
e
> > since we postpone all RX to the tasklet. But the tasklet seems to be ok
> > -- so should it really be in_interrupt()?
>=20
> I think a tasklet is also in_interrupt(), because it's a softirq.

Ah, yes, indeed, in_interrupt() vs. in_irq().

johannes

--=-yurZqWm/P6lWkQy5ETrt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKw3dqAAoJEODzc/N7+QmaD/8QAMl79xODqhLGqkDnHqDveUFc
cBHynUlxouy4Pp2ssl5RoaDnkeV5X4+gW+zWn8EH1HHcMwux2QOJn99ozecgYPwD
CWwVbvdhThnCdtBC353oDwcms0dY8WM2WNesbgaWkJjN2EfaduSHFV1xT1h/i/rP
z4FTGJx8XK2rrZ5GOmGOZXjF2Cilteny1X9n018Hi6nNnNlgjjIVCrdyVrPr7rvj
4VGuD97Jy0XQJWNudRGBUTrtvsjq0+0Juiy2re+M+hA+ZrldXE6lyD2fidpBrsv5
aiWxHjFwD3NzNEGKPaMOdVw1eIhZ+1yJS1JKPD9Cm9xnoChbjwm/QQDOJW0XzMtD
5Zt2Th2rqs6aqOpBXgGbJdGOvoXgDxlmS3pZBrQvvN8bXlapb1U/94N1CwQb9Fnp
CmaqawBNRbOatv05sANokV4Sqiqa4RfLZ/7MnTCWyv1x7rfAge7hg4964tURNk9q
1DZS9054nXetz97hibrF6OOgMh/O7HBjrkU+5diiT6lSNZsdk6LmfOkt84xFKTAn
dIoow2mjiKOhDTePR8WLJBLDhh7CmGEcCDJm29s+WzW2Y1y99S6u8AmCeFZuBttz
moc61Ty3XI0Affrfr7iPttmTCNTOx6ToCW/2Bly8NS2H/jZJBc+M3TjprlSW/oGX
ntHHfPU6Mh1Qzhvq2o46
=a2hw
-----END PGP SIGNATURE-----

--=-yurZqWm/P6lWkQy5ETrt--

