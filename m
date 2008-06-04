From: martin f krafft <madduck@madduck.net>
Subject: Re: non-root, non-real network manipulation for netconf testing
Date: Wed, 4 Jun 2008 11:13:21 +0200
Message-ID: <20080604091321.GB20153@lapse.madduck.net>
References: <20080603080529.GA9010@lapse.madduck.net> <20080603100513.GA18161@solarflare.com> <20080603102050.GA14461@lapse.madduck.net> <20080603104709.GB18161@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QTprm0S8XgL7H0Dt"
To: netdev discussion list <netdev@vger.kernel.org>,
	netconf developers list <netconf-devel@lists.alioth.debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seamus.madduck.net ([213.203.238.82]:60899 "EHLO
	seamus.madduck.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755129AbYFDN5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 09:57:04 -0400
Content-Disposition: inline
In-Reply-To: <20080603104709.GB18161@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--QTprm0S8XgL7H0Dt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

also sprach Ben Hutchings <bhutchings@solarflare.com> [2008.06.03.1247 +020=
0]:
> I don't believe that's the case for UML.

You're right. I spent some time with UML yesterday and got it to the
point where it can run an command in a UML and report back the
status code without requiring any setup or root rights. If you're
interested:

  http://git.debian.org/?p=3Dnetconf/netconf.git;a=3Dtree;f=3Duml;hb=3Dumlt=
est

Now I need to figure out how to set up uml_switch as a user such
that I can have two or three interfaces within the UML on the same
network segment.

Right now, my problem is that if eth0-2 have 1.2.3.1-3 assigned to
them, pinging 1.2.3.2 from 1.2.3.1 will make Linux route the packets
via loopback. I need to figure out how to make them be put on the
wire (which is uml_switch in this case).

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
"whale feces or working at microsoft? i would probably be the whale
 feces researcher. salt air and whale flatulence; what
 could go wrong?"
             -- michael moyer, executive editor of _popular science_
=20
spamtraps: madduck.bogus@madduck.net

--QTprm0S8XgL7H0Dt
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIRlyxIgvIgzMMSnURAq19AKCP6+ToESLAXl6WHjCHQAuyelUh4wCdGSVI
GgyWrOG57m0s8kKzrcVkfwQ=
=Pzej
-----END PGP SIGNATURE-----

--QTprm0S8XgL7H0Dt--
