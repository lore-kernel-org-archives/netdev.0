From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 15:55:03 +0200
Message-ID: <200605101555.03963.IvDoorn@gmail.com>
References: <200605061401.01795.IvDoorn@gmail.com> <200605100001.20180.IvDoorn@gmail.com> <20060510125241.0bb0978b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5859283.XrXNucckAT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Olivier <o.cornu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:9837 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751191AbWEJOAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 10:00:20 -0400
Received: by nf-out-0910.google.com with SMTP id k26so378956nfc
        for <netdev@vger.kernel.org>; Wed, 10 May 2006 07:00:19 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060510125241.0bb0978b@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5859283.XrXNucckAT
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 10 May 2006 12:52, Jiri Benc wrote:
> On Wed, 10 May 2006 00:01:16 +0200, Ivo van Doorn wrote:
> > Basicly the dscape stack is performing active scanning while the device=
 is down,
> > but during the active scan it is sending packets out, or at least attem=
pting to do so.
> > Besides the question if active scanning is preferred over passive scann=
ing while interface is down,
> > active scanning fails because the packets that should be send are being=
 send through the regular
> > xmit routines of the interface. (IFF_UP is not set for the interface)
>=20
> When all interfaces are down, the card must be completely disabled. No
> transmitting, no receiving. Currently, there is a (minor) bug in IBSS
> code in d80211 stack which tries to perform scanning even when the
> interface is down. It's not so important because generated probe
> requests are never delivered to the driver if the card is disabled (i.e.
> no interfaces are up).
>=20
> > This means that besides enabling the radio which should be done in the =
driver, the stack should either bring
> > up the interface when doing an active scan, or resort to passive scanni=
ng while interface is down.
>=20
> The stack should not perform any scanning when the interface is not up.

Ok thanks. Along with the previous mail about the add_interface and remove_=
interface this
clears up some misunderstanding about the scanning behaviour. ;)

Ivo

--nextPart5859283.XrXNucckAT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEYfC3aqndE37Em0gRAp7EAJ0d9q9C+Ab62Vr9CK0+ikoBBkoCAgCg1jEA
kmr5YnsX+5FKa3UK/OCQ6l0=
=u7Km
-----END PGP SIGNATURE-----

--nextPart5859283.XrXNucckAT--
