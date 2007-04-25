From: Ismail =?utf-8?q?D=C3=B6nmez?= <ismail@pardus.org.tr>
Subject: Re: Problem with commit a0ee18b9b7d3847976c6fb315c06a34fb296de0e
Date: Wed, 25 Apr 2007 16:50:35 +0300
Message-ID: <200704251650.36773.ismail@pardus.org.tr>
References: <200704231506.34410.ismail@pardus.org.tr> <200704240023.13565.ismail@pardus.org.tr> <200704251152.52906.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1577899.xjURKT4k6S";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:55431 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030332AbXDYNtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 09:49:18 -0400
In-Reply-To: <200704251152.52906.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1577899.xjURKT4k6S
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 25 April 2007 11:52:52 Ismail D=C3=B6nmez wrote:
> Hi,
>
> On Tuesday 24 April 2007 00:23:13 Ismail D=C3=B6nmez wrote:
> > On Tuesday 24 April 2007 00:17:40 Thomas Graf wrote:
> > > * Ismail D?nmez <ismail@pardus.org.tr> 2007-04-23 22:09
> > >
> > > > Yes I know the fix is in but I wondered why its creating such
> > > > problems with 2.6.18 kernel, guess it depends on some other commits.
> > >
> > > As long as you apply the complete patch including the additional
> > > sanity check for RTN_MAX it should work perfectly fine on 2.6.18.
> >
> > The sanity check part doesn't seem to apply to 2.6.18.
> >
> > > I can't think of any connection between the patch and the errors
> > > you are seeing.
> > >
> > > Are you absolutely sure the errors you see are directly connected
> > > to applying the patch?
> >
> > Yes actually I am but I'll re-test and see. Thanks.
>
> I was able to reproduce the same problem with Linus' GIT tree too. Since I
> started to see these after I applied the commit
> a0ee18b9b7d3847976c6fb315c06a34fb296de0e to 2.6.18 tree, there is a big
> possiblity that the commit is the culprit.
>
> I attach the relevant dmesg messages. Problem happened after 12 hours of
> uptime and and net connection gets stable again after 1-2 minutes.

Ignore this my laptop seems to be totally dying now including wireless card=
=20
too. Sorry for the noise.

Regards,
ismail

=2D-=20
Life is a game, and if you aren't in it to win,
what the heck are you still doing here?

=2D- Linus Torvalds (talking about open source development)

--nextPart1577899.xjURKT4k6S
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iD8DBQBGL1ysGp0leluI9UwRAgULAJwO9dh/SKkBON9fAkUZD/4dc/N6gACfaOMU
FX86QUKoEi0tuGV3gWfmZTU=
=5RCn
-----END PGP SIGNATURE-----

--nextPart1577899.xjURKT4k6S--
