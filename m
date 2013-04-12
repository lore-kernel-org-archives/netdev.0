From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Fri, 12 Apr 2013 08:04:34 +0100
Message-ID: <20130412070434.GA2729@raven>
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
	protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:39011 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329Ab3DLHEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 03:04:37 -0400
Content-Disposition: inline
In-Reply-To: <1365702804.3887.180.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3/rZRmxL6MmkK24
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

Many thanks for this updated patch, Eric.  I will test here as soon as I
can and report back -- this will likely be some time next week.

--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRZ7ICAAoJEJSMBmUKuovQAnQIAKtmm6f/uEIMkpm0JQHQUsgd
YPh2RMS+MYJz9npN4/B28wEn7DNdl5RDPYTnVuNBQhEbOhqJBeX6BgfeFJ2ZG9eE
F9q9XHRLOqJPkLjFQ60EYtlKZDZGMop32jqw9HaZncibI7z6QRABetGAk8NQAwTx
KDra4XIbjlypDPWkVaEDb2YXcbF6cB0Svhpw96jsBFDMIvMpQYmFE2iR8ix1whoT
XPye2GpjGIVWXWLkaz0XA+LtMQFif5N+mRqzPKJviOuM5xV32CsyKN9UgSOBABvc
D7rnZiVPYhYrnVEW1UraYZH8HkOca8F4Rw6lf7tM1vdhYaLTMbobtlVRNqZITa8=
=a7+p
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
