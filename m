From: "D. S. Ljungmark" <spider@takeit.se>
Subject: Re: Responsible Disclosure
Date: Tue, 24 Mar 2015 20:31:01 +0100
Message-ID: <1427225461.3276.1.camel@takeit.se>
References: <1425861908.8414.12.camel@modio.se>
	 <20150309054916.GA8575@kroah.com> <1427153139.14059.2.camel@takeit.se>
	 <20150324184517.GA24177@kroah.com>
Reply-To: ljungmark@modio.se
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-cSnKmQJCVCmsA2GJRK3+"
Cc: ljungmark@modio.se, "security@kernel.org" <security@kernel.org>,
	security <security@android.com>, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:32994 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbbCXTbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:31:12 -0400
Received: by lbcmq2 with SMTP id mq2so2266716lbc.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 12:31:10 -0700 (PDT)
In-Reply-To: <20150324184517.GA24177@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cSnKmQJCVCmsA2GJRK3+
Content-Type: multipart/mixed; boundary="=-StdQSdmGMqC4xZJOJ9hC"


--=-StdQSdmGMqC4xZJOJ9hC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On tis, 2015-03-24 at 19:45 +0100, Greg KH wrote:
> On Tue, Mar 24, 2015 at 12:25:39AM +0100, D. S. Ljungmark wrote:
> > On m=C3=A5n, 2015-03-09 at 06:49 +0100, Greg KH wrote:
> > > On Mon, Mar 09, 2015 at 01:45:08AM +0100, D. S. Ljungmark wrote:
> > > > Hi.
> > > >   We have developed a somewhat disturbing DoS attack (due to a logi=
c
> > > > error) that affects _at least_ :
> > > >=20
> > > >   Windows 8.1 (32bit)=20
> > > >   Mac OS X  10.10
> > > >   FreeBSD 10.1
> > > >   Linux 3.x (samples between 3.0 =3D> 3.18 tested)
> > > >   Android  (Lollipop)=20
> > > >=20
> > > > Now, we have a problem with reporting this, in that it doesn't only
> > > > apply to a single OS/implementation.=20
> > > >  =20
> > > > The mitigation is fairly simple ( in lines of code ) and we have a =
patch
> > > > for Linux already.=20
> > > >=20
> > > > There is a working proof of concept, and the cause might be attribu=
ted
> > > > to a somewhat naive interpretation / concept in an IETF RFC, that h=
as
> > > > since been amended, but not fixed in implementations.
> > > >=20
> > > >=20
> > > > I am not going to dump this as a bombshell by dropping it on Slashd=
ot or
> > > > similar and watching the fallout as many of the worlds shared hosti=
ng
> > > > services drop offline from malicious usage.=20
> > > >=20
> > > > On the other hand, I'm not going to give certain parts prior knowle=
dge
> > > > with example PoC just because they feel privileged and want to dela=
y
> > > > this for unreasonable amounts of time.  We're all adults here, and =
know
> > > > how to communicate this.
> > > >=20
> > > > Who can organize a coherent Review / Analysis / Patch / Disclosure =
of
> > > > this? Where do I start? Who do I contact?=20
> > > >=20
> > > > We're trying to do the right thing here, but there isn't much docum=
ented
> > > > on how to report cross-platform bugs that has the possibility of ca=
using
> > > > larger breakage.
> > >=20
> > > The linux-distros mailing list is your best bet.  They replaced the o=
ld
> > > vendor-sec mailing list.  They can help you out here with notifying
> > > everyone involved and generating a fix properly.
> > >=20
> > > Hope this helps,
> > >=20
> > > greg k-h
> >=20
> >=20
> > Following up with the patch, got an okay from CERT to post it.
> >=20
> > Signed-Off-By: D.S. Ljungmark <ljungmark@modio.se>
>=20
> What patch?  I didn't see anything here :(
>=20
> Did you sent it to netdev@vger.kernel.org?
>=20
> If not, can you please do so, that way the kernel networking developers
> can see it and apply it.
>=20
> thanks,
>=20
> greg k-h

This patch prevents a link-local DoS against ipv6.=20


To exploit, push an RA packet without any routing information, but with
the hop limit reduced to 1.

//D.S. Ljungmark







--=-StdQSdmGMqC4xZJOJ9hC
Content-Disposition: attachment; filename="linux-3.18-ipv6-hop_limit.patch"
Content-Transfer-Encoding: base64
Content-Type: text/x-patch; name="linux-3.18-ipv6-hop_limit.patch"; charset="UTF-8"

ZGlmZiAtdXJ3IGxpbnV4LTMuMTguNy0yMDAuZmMyMS54ODZfNjQvbmV0L2lwdjYvbmRpc2MuYyBs
aW51eC0zLjE4LjctMjAwLmZjMjEueDg2XzY0L25ldC9pcHY2L25kaXNjLmMKLS0tIGxpbnV4LTMu
MTguNy0yMDAuZmMyMS54ODZfNjQvbmV0L2lwdjYvbmRpc2MuYwkyMDE1LTAzLTA4IDEzOjAxOjM2
LjU2NzAwMDAwMCAtMDQwMAorKysgbGludXgtMy4xOC43LTIwMC5mYzIxLng4Nl82NC9uZXQvaXB2
Ni9uZGlzYy5jCTIwMTUtMDMtMDggMTI6NTA6NTUuNDQ2MDAwMDAwIC0wNDAwCkBAIC0xMjE1LDcg
KzEyMTUsMTUgQEAKIAlpZiAocnQpCiAJCXJ0Nl9zZXRfZXhwaXJlcyhydCwgamlmZmllcyArIChI
WiAqIGxpZmV0aW1lKSk7CiAJaWYgKHJhX21zZy0+aWNtcGguaWNtcDZfaG9wX2xpbWl0KSB7CisJ
CS8qCisJCSAqCU9ubHkgc2V0IGhvcF9saW1pdCBvbiB0aGUgaW50ZXJmYWNlIGlmIGl0IGlzIGhp
Z2hlciB0aGFuIHRoZSBjdXJyZW50IGhvcF9saW1pdC4KKwkJICoJUHJldmVudHMgc2lsbHkgcm91
dGVzIHdpdGggaG9wX2xpbWl0IDEgZnJvbSBhZmZlY3RpbmcgZXZlcnlvbmUuCisJCSAqLworCQlp
ZiAoaW42X2Rldi0+Y25mLmhvcF9saW1pdCA8IHJhX21zZy0+aWNtcGguaWNtcDZfaG9wX2xpbWl0
KSB7CiAJCWluNl9kZXYtPmNuZi5ob3BfbGltaXQgPSByYV9tc2ctPmljbXBoLmljbXA2X2hvcF9s
aW1pdDsKKwkJfSBlbHNlIHsKKwkJCU5EX1BSSU5USygyLCB3YXJuLCAiUkE6IEdvdCByb3V0ZSBh
ZHZlcnRpc2VtZW50IHdpdGggbG93ZXIgaG9wX2xpbWl0IHRoYW4gY3VycmVudFxuIik7CisJCX0K
IAkJaWYgKHJ0KQogCQkJZHN0X21ldHJpY19zZXQoJnJ0LT5kc3QsIFJUQVhfSE9QTElNSVQsCiAJ
CQkJICAgICAgIHJhX21zZy0+aWNtcGguaWNtcDZfaG9wX2xpbWl0KTsK


--=-StdQSdmGMqC4xZJOJ9hC--

--=-cSnKmQJCVCmsA2GJRK3+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJVEbt6AAoJEPzDdnREnjz8b88P/08kqDPnJF51MPhGKTpqy6+w
Y/ilnRXfX5vXMogrPUGqWSoyHPjhw2CwbcSqwdX4YBxnsaAWGmwuWqFdLbxA003q
2+XtGRvtxml2rmyV5UWHdSqRLLBi8PNHE+10Fd0lquu8O32UyHTn8lbN+hlfb93Y
lsZOPLp4LgVDAgILYW5pfMvp8pzUTxuGwykwDWl8nwNJ2NlZQ/KaNUA0I+ZsOQnb
8DlR8meINBI+pRFZ/rTbVqMQZMZoX3DHDySiu8onxABm3AMq4zdLWOJ0evnM3139
Pyj/4taCsmaEPsm73NxQMyo2z58UV60Ud632KypnGezYabDr+EtLqyHBYzOP9OfZ
zSfqvt3JHPVFrLP6E1HgJi462Zduu8pO9VZvHJM7F2hOLehNU2ofbfT2nLodFbwn
JeyUeg8zI1Aevn3vF5o7+OD40pAvIvgYHO/KYtiDXzFfMsbcQoD1tjo+3zgj3Es7
oUbckS5bro+6WrC191jm5tHacorLYiO2wGdCRjtWnSWAlonVshjNaKbqOZOvMQ5B
8soVfE/KRGU3Najc91HJh5koUl14Z2C6NGBLoitNknHB4eneCu2NJNagHNmh5xF8
ShPn/Xf0PcqEU4bx62TeVnGj7gReIAMj27SJJYSsZzDG1vPuXsRcwCtt+Zq+Jn+X
sJYknhkwHSJEtisgnwex
=i6EZ
-----END PGP SIGNATURE-----

--=-cSnKmQJCVCmsA2GJRK3+--
