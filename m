From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#577640: linux-image-2.6.33-2-amd64: Kernel warnings in
 netns  thread
Date: Thu, 22 Apr 2010 01:14:38 +0100
Message-ID: <1271895278.2582.3.camel@localhost>
References: <20100413112017.8505.36380.reportbug@japot.localdomain>
	 <1271612005.3679.248.camel@localhost>
	 <o2jb9800b71004210819t6ca61099y17be143527ccbc95@mail.gmail.com>
	 <m1ljcgzjh4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-84m/2HAnvdYHWmJcG+lz"
Cc: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>,
	577640@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48694 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756235Ab0DVAPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 20:15:03 -0400
In-Reply-To: <m1ljcgzjh4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-84m/2HAnvdYHWmJcG+lz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-04-21 at 12:36 -0700, Eric W. Biederman wrote:
> Mart=C3=ADn Ferrari <martin.ferrari@gmail.com> writes:
>=20
> > I'm not starting a new thread/bug, as this is probably related...
> >
> > I just discovered that in 2.6.33, if I create a veth inside a
> > namespace and then move one of the halves into the main namespace,
> > when I kill the namespace, I get one of these warnings followed by an
> > oops. This does not happen if the veth is created from the main ns and
> > then moved, nor in 2.6.32. This happens both in Qemu and on real
> > hardware (both amd64)
> >
> > To reproduce:
> >
> > $ sudo ./startns bash
> > # ip l a type veth
> > # ip l s veth0 netns 1
> > # exit
>=20
> Nasty weird. I did a quick test here, and I'm not seeing that.
> Does the 2.6.33 experimental kernel have any patches applied?

Yes, but not many beyond the stable updates, and nothing in this area.
You can see the list at:
http://svn.debian.org/wsvn/kernel/dists/trunk/linux-2.6/debian/patches/seri=
es/base

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-84m/2HAnvdYHWmJcG+lz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS8+U6ue/yOyVhhEJAQJzMxAAmWKEGGf8TvAMz1L+ovmA0JRNA/wDNQMx
To/kLtlsL2mz3FcbaEi8yKh74Bbaitneoh7UVGmqCY8kk+BeegnVaZk6ZT0P974E
QP+R5FIuTdWhiUX4GgLX5/ga+zrnBWVYlPA3Cm1f0ZQmJOFr82b9N15pInDiUqFw
YLMuBiyuRFMUZ1Nwcr4VN+xKY+TzmO/HoSmgfa2qtr/0gIIReoIcoGWoiYsub6yx
52mgQSklf3r/+i9b9fyONdj1l0a0oAZDpP8yNm+KvzUPtj+U6V03G0gFDvko92zD
LF/EI4pNmsN3wIrZ7bqwhLwFnr2GCdK+okmL7Thx6a1HSNPjtpQuwh3IIMIlmWsO
wKMnbvsFPZrfjv4KXV1as1NgiCGsu/SwrIo9oGpafpw3p0h2A5cAUr1/SSvSJ/5u
5oVFceS1dHC9w0FNd6XCsSNexZYAhUVCNl+3yfDH2GWFdayWeVu1uWWiJoTBHjDC
TJUHKF2RUr+RXbeC0D5RV07q9aMJv0cPIyG4SZXYgWMiKjjayn2ykW4t+0/XtTY+
EbAGrq7QFfRoDu9kGPkfaoMAfB+5phWKWKV1d95hV0PafO+dLRddjjMn6ZBalVnp
bIXr30koS0o/UXQjOUz6rSsn2bjTKiWEghO7oEnHUznBGvWtmAe6K/AsmPGbb06H
W+xxLQDdLRA=
=IGBM
-----END PGP SIGNATURE-----

--=-84m/2HAnvdYHWmJcG+lz--
