From: Douglas Pollock <douglas.pollock@magma.ca>
Subject: Re: Realtek 8169 Lock-ups
Date: Fri, 23 Jan 2004 08:00:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074862857.5324.5.camel@localhost>
References: <1073507006.5151.61.camel@localhost>
	 <20040107232034.A22930@electric-eye.fr.zoreil.com>
	 <1073596694.6378.6.camel@localhost> <4001080D.3090401@pobox.com>
	 <20040111124957.A18068@electric-eye.fr.zoreil.com>
	 <20040113000357.D5983@electric-eye.fr.zoreil.com>
	 <1074020596.5336.0.camel@localhost>
	 <20040114005738.B21899@electric-eye.fr.zoreil.com>
	 <1074449824.5286.4.camel@localhost>
	 <20040119005555.A1399@electric-eye.fr.zoreil.com>
Reply-To: dpollock@acm.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sQ6kmFs/slsZ5DDEBcPb"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040119005555.A1399@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-sQ6kmFs/slsZ5DDEBcPb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Francois,

Many apologies.  It was my own stupidity.  I've sorted things out, and
am now running 2.6.1-bk1 with your patchset.

With SMP enabled, I get a timeout from the watchdog and my network
connection becomes unresponsive.  In fact, during boot the DHCPC server
times out looking for an IP address.

I tried changing (boguscnt > 0) to (1 > 0) and this made no difference.

Both of these tests were run with 1000 9014-byte packets.

Even with SMP disabled, and even with the patches not applied, there seems =
to be problems (this is on 2.6.1-bk1).  Perhaps I just wasn't seeing them e=
arlier.  Basically, sometimes the packet generator completes normally the f=
irst time.  Sometimes, it does not.  Either way, by the second run of the p=
acket generator, the network device stops responding.

I will try the most recent kernel and patch set, and see what problems I ge=
t.



Doug.



--=-sQ6kmFs/slsZ5DDEBcPb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAERsHLhh1LVU8SusRAuHaAKCiiyfIFnovSa5WfZr85n9wQ5IbEQCgghnd
qc2Bxn0I1YcFXcy38wKsnz8=
=yyOs
-----END PGP SIGNATURE-----

--=-sQ6kmFs/slsZ5DDEBcPb--
