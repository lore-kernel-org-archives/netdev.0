From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Tue, 16 Apr 2013 21:20:22 +0100
Message-ID: <20130416202022.GB2545@raven>
References: <1362695800-8633-2-git-send-email-tparkin@katalix.com>
 <1362696444.15793.220.camel@edumazet-glaptop>
 <20130307.181527.390191009324148471.davem@davemloft.net>
 <20130313232743.GA3686@raven>
 <1363223884.29475.0.camel@edumazet-glaptop>
 <20130314144550.GB2512@raven>
 <1363273531.29475.21.camel@edumazet-glaptop>
 <1363274946.29475.24.camel@edumazet-glaptop>
 <1365697961.3887.176.camel@edumazet-glaptop>
 <1365702804.3887.180.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fba/0zbH8Xs+Fj9o"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:39186 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965099Ab3DPUUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 16:20:25 -0400
Content-Disposition: inline
In-Reply-To: <1365702804.3887.180.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Fba/0zbH8Xs+Fj9o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 11, 2013 at 10:53:24AM -0700, Eric Dumazet wrote:
> On Thu, 2013-04-11 at 09:32 -0700, Eric Dumazet wrote:
>=20
> > Short update : I do not understand yet why this patch is not working.
> >=20
> > Normally, the reassembled packet should get the dst from the last skb
> > (the one completing the packet)...
> >=20
> > I have to make more experiments.
>=20
> OK I think I've nailed it, please try following patch (I tried it on
> net-next, but it should apply on previous kernels)
>=20
> Thanks !

Thanks Eric, I've tested this patch here and it looks good.  Usually I
see an oops within 30 mins or so with my workload, but with this
change I've run for over two hours with no issues.

--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--Fba/0zbH8Xs+Fj9o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRbbKGAAoJEJSMBmUKuovQB9EH/i5+HBY0Lcxd0jiUydtQFdbA
XoLU0jj4pyKUTWmEhWBUCxh97RZUHwNaPbx7zJbrGWYrzhNTQHODd7PkkB9jRGSx
D6JcUdvxI4+qQkMOuxuLLKJZmP9SgiXTFTQeHswnXunxJESCxhXwFo1hP4feGKP8
PnPMFgWNVzuptsXr69wj/VFE5ePhzgqIRDG3Iao/n6ECr/EO3/A6l1Alq5tHIdTp
T8c34h5RcOqZLXIMRHI60u3qAh7Q1EFmQCO2tyADRQmnyQy3PcjugaAvHvCvsBao
MDYSwy/80Dc43lstox3ac7AyqV3/jrCy8ebb3Rn+PL7U6zfh9GWGXve5/yqrY10=
=nBxN
-----END PGP SIGNATURE-----

--Fba/0zbH8Xs+Fj9o--
