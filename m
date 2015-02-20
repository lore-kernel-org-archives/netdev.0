From: Simon Farnsworth <simon@farnz.org.uk>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is received
Date: Fri, 20 Feb 2015 11:17:26 +0000
Message-ID: <3411251.Z29qxOyJF6@f19simon>
References: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2135903.MQyUFCe5xD"; micalg="pgp-sha1"; protocol="application/pgp-signature"
To: netdev@vger.kernel.org, Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claranet-outbound-smtp00.uk.clara.net ([195.8.89.33]:39354 "EHLO
	claranet-outbound-smtp00.uk.clara.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753431AbbBTMFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 07:05:18 -0500
In-Reply-To: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2135903.MQyUFCe5xD
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

Michal's e-mail as listed in MAINTAINERS is bouncing (he's listed as PP=
PoE
maintainer).

If anyone has alternate contact details for him, please let him know th=
at
his kernel-related e-mail is bouncing.

The relevant chunk of MAINTAINERS is:

PPP OVER ETHERNET
M:      Michal Ostrowski <mostrows@earthlink.net>
S:      Maintained
F:      drivers/net/ppp/pppoe.c
F:      drivers/net/ppp/pppox.c

If I don't hear from him in the next couple of weeks, I'll send the tri=
vial
patch to remove PPP OVER ETHERNET from maintained status.

On Thursday 19 February 2015 21:24:28 Simon Farnsworth wrote:
> When a PADT frame is received, the socket may not be in a good state =
to
> close down the PPP interface. The current implementation handles this=
 by
> simply blocking all further PPP traffic, and hoping that the lack of =
traffic
> will trigger the user to investigate.
>=20
> Use schedule_work to get to a process context from which we clear dow=
n the
> PPP interface, in a fashion analogous to hangup on a TTY-based PPP
> interface. This causes pppd to disconnect immediately, and allows too=
ls to
> take immediate corrective action.
>=20
> Signed-off-by: Simon Farnsworth <simon@farnz.org.uk>
> ---
> Note that I'm not subscribed to netdev; please cc me on any replies.
>=20
> The patch falls out of https://bugzilla.gnome.org/show_bug.cgi?id=3D7=
42939
> I'm trying to get NetworkManager back to using kernel PPPoE partly be=
cause
> it performs a little better, and mostly because kernel PPPoE copes wi=
th
> larger MTUs than userspace PPPoE.
>=20
> Dan Williams (cc'd) has tested a previous version of this patch; the
> differences to this version are only cosmetic.
>=20
>  drivers/net/ppp/pppoe.c  | 17 ++++++++++++++++-
>  include/linux/if_pppox.h |  2 ++
>  2 files changed, 18 insertions(+), 1 deletion(-)
>=20
<snip patch>

=2D-
Simon Farnsworth

--nextPart2135903.MQyUFCe5xD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABAgAGBQJU5xfKAAoJEOsKZy3xM+c75N4IALCDg4pOBmskGvM08xLj/WIK
5tCs0wcoBb0ZEj9JX/3jV9Mw0FLsiqMinml9iwLN5v1xWK46bvaGDfLFT9VKJ9gK
bFV0atACj7XHbyZDem4oj83AT7eIefNS+kMfk5kMu3CdSFoLByCAbgASJodTk0rx
CB61exhorDYCdTT9MqJOZLjSlIOMyqxkiYMgiljZ7Peb076Q1HjH7FIuE61yDf91
D7dSNetnCWbBH8u90DV+94dq6YVFP3KwRLbFZCBqZs/Kwv58cCpYNSm+X10YZLux
pFbVuB+BEz6mBJxcdqZHc2aWww3ujPEmyB00ONsKHJhE8rUzeme8x11aru6Y4cU=
=2lL3
-----END PGP SIGNATURE-----

--nextPart2135903.MQyUFCe5xD--
