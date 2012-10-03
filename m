From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM Bladecenter
 SoL
Date: Wed, 03 Oct 2012 01:17:12 +0100
Message-ID: <1349223432.16173.10.camel@deadeye.wl.decadent.org.uk>
References: <87txuhho5z.fsf@lant.ki.iif.hu>
	 <1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <87a9w5dqle.fsf@lant.ki.iif.hu>
	 <1349190185.5420.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <87haqcddks.fsf@lant.ki.iif.hu>
	 <1349197607.5420.25.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <87626sd80j.fsf@lant.ki.iif.hu> <506B3B52.7080001@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jW9i/cAqqWcZPssdvSkp"
Cc: Ferenc Wagner <wferi@niif.hu>, Michael Chan <mchan@broadcom.com>,
	netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Michael Tokarev <mjt@tls.msk.ru>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41214 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932864Ab2JCARm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 20:17:42 -0400
In-Reply-To: <506B3B52.7080001@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jW9i/cAqqWcZPssdvSkp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-10-02 at 23:06 +0400, Michael Tokarev wrote:
> On 02.10.2012 22:49, Ferenc Wagner wrote:
> > "Michael Chan" <mchan@broadcom.com> writes:
> >> These are the likely fixes:
> >>
> >> commit cf9ecf4b631f649a964fa611f1a5e8874f2a76db=20
> >> Author: Matt Carlson <mcarlson@broadcom.com>
> >> Date: Mon Nov 28 09:41:03 2011 +0000
> >>
> >> tg3: Fix TSO CAP for 5704 devs w / ASF enabled
> >=20
> > You are exactly right: cf9ecf4b fixed the premanent SoL breakage
> > introduced by dabc5c67.  Looks like ASF utilizes similar technology to
> > that of the HS20 BMC.  Thanks for the tip, it greatly reduced our CPU
> > wear. :)  It's a pity ethtool -k did not give a hint.  Do you think it'=
s
> > possible to work around in 3.2 by eg. fiddling some ethtool setting?
>=20
> Maybe it's better to push this commit to -stable instead?

But that will take time, so I imagine a temporary workaround would be
useful to Ferenc.

> (the commit
> that broke things is part of 3.0 kernel so all current 3.x -stable
> kernels are affected)
[...]

The fix went into 3.3, so only 3.0 and 3.2 need it.

David, please can you include the above commit in your next batches for
these stable series?

Ben.

--=20
Ben Hutchings
For every complex problem
there is a solution that is simple, neat, and wrong.

--=-jW9i/cAqqWcZPssdvSkp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUGuECee/yOyVhhEJAQp6lRAA0NpZTL6AlgNhaV+xQqkaD7Iho4V0S4lS
/q0HVfgojE9215gL04mOjouKiwJrsdhSx73b7/zrLiQRJF5T9gAyn3+TkkCqAgSM
z5t4ml63Wcw6TyNVAonrFYE0jpI7vrtoMjQ1L35/+UiMCRIM3oS/A5IJrkvb4A+o
JxX8AJl8FNPThyp+QOV3B1GdY9bQAzoRoP4PbhcWN9cauYsE0wlGQSjGmbszS2tN
THoDtGZMBCOQ7pyr99SPCw9swmZvw5MnrjuQO9wuM54dCYWzT6pJTKya+EBAdi1g
sQBhFEV3kcDjyY9lNdTnopbzNUHT+qw2HXIbnocsvHYW+lDqywK8bubkmgx5knkJ
DH9AWQhXZ7YTEK1H/tRRoUF6gFKkzIODAuR4Df6ILkfV3rkmLrYAo4RNIAhK/vkG
T3Y/gMCjY8C4cLkSDQeobCDlO5HopCfjJFSvok8UQH98F01psemJo8iv+NLps0RA
2D0Ocxw25NDm6IAYvRTBJvsKLY5ky/TiFp92mh/XDL/TFY5qDG+HmFB2W2n92iuO
bHIduJ7iQ+CdzBRNwgrzkN1YcAT/C2Aoe5e1bLZk6KRQWBANBb5C3XI1nn3ouNIv
a7txJbq515tliZghsi6RftfeXjpD9mdkdNs64L6AQD7ypxX89fdnbPsXJPM0K0zh
WtQOTXQ/OTo=
=2w/Z
-----END PGP SIGNATURE-----

--=-jW9i/cAqqWcZPssdvSkp--
