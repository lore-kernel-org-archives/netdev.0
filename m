From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#709616: floods the network with pause packets
Date: Thu, 30 May 2013 13:58:44 +0100
Message-ID: <1369918724.3469.445.camel@deadeye.wl.decadent.org.uk>
References: <20130524124059.12781.51344.reportbug@wencory.loria.fr>
	   <20130524160727.GM4752@decadent.org.uk> <51A07081.5010104@debian.org>
	  <1369533273.3469.301.camel@deadeye.wl.decadent.org.uk>
	  <51A1CFB7.1080808@debian.org>
	 <1369584645.3469.343.camel@deadeye.wl.decadent.org.uk>
	 <51A719FD.9020506@debian.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bXC8hIp4znNwy8Tski3Z"
Cc: 709616@bugs.debian.org, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?St=E9phane?= Glondu <glondu@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59211 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752877Ab3E3M66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 08:58:58 -0400
In-Reply-To: <51A719FD.9020506@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bXC8hIp4znNwy8Tski3Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-05-30 at 11:21 +0200, St=C3=A9phane Glondu wrote:
> Le 26/05/2013 18:10, Ben Hutchings a =C3=A9crit :
> > OK, so the switch is indeed defective: it says it can handle pause
> > frames, but it can't.
>=20
> The problem happened on (at least) two different switches from different
> manufacturers (Transtec and Netgear).
>=20
> FWIW, the problem just happened on another machine (with same hardware)
> this morning. It is running Ubuntu with kernel 3.5.0-31-generic.
>=20
> > Could you check whether the switch is also sending pause frames back to
> > the port that's generating them?
>=20
> How exactly do I do that? Is disconnecting the faulty computer and
> connecting my laptop in its place right?

ethtool -S eth0 | grep flow_control

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-bXC8hIp4znNwy8Tski3Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUadNBee/yOyVhhEJAQobPhAAhi+szyAaudMEy5dTN7iMAs+AjqB8BqBQ
8F7bJPra64G3PnxRLJhzF1nx47i+Y7STeYfqQ59v4fjWMHgaPptKQsesmJTfx7EH
EyZ1BbLw3lnY5yuXW3TXd9EFtChh0bcSyaMrcqQN9C2BPPxVRdzX1JzRPoItIZ5/
0oaFBmD3EJTWDB57ivdEa8+d1g1FUeklWyjwsHwDgXQlSWGn3p9wgGUQQC95JCMy
SeCk5kIrB0Eiq3+pG5Lfm/TYwCepqgw7QLpZLp38rGaXYBOLTMp8Mfxi2kSQAXMq
Zpci8ZP2ZA2Rd4WnIshnn0Yy/Es17XI57jyRn7qZLe4Kz9yLdHg59GHWKfJ1XKL+
22fwZRoisyTF04KTbsuSfKjcQT6O/uScs0DAj2+er5EiVBVoo0lu74mcNVez7cZ0
WGwGUOAJM0b1Xc3cncmEAMUyHYEsLJSyZFI8++Oyg9xMgzX+RFXUSyxFLV93n1sQ
Q69C/dGFxM8rsGH9REZ+WdlDytIh2H2GVZ8y7izolxpZxbCXJKdJMgQ8NBMx28+4
/V2kwrhjJ1jBG/WxoccOpgPmA5umSLjRvr32SMtYiHTdz3b3Dm1WC2Zy28Lrh9l5
O/IEPO08PioaOVL2GdIFWLDMzSOfjm6wXEd0mNYqqZiqJDM3++Bi5aGfMJruPWGK
J8n/XOnvtps=
=RA2H
-----END PGP SIGNATURE-----

--=-bXC8hIp4znNwy8Tski3Z--
