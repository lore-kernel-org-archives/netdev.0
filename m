From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 9 Dec 2010 14:02:07 +1100
Message-ID: <20101209140207.967a5ad5.sfr@canb.auug.org.au>
References: <20101209132836.6f6acfb8.sfr@canb.auug.org.au>
	<20101208.183942.226776000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__9_Dec_2010_14_02_07_+1100_ywj4ePD4lablXUF7"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, socketcan@hartkopp.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101208.183942.226776000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__9_Dec_2010_14_02_07_+1100_ywj4ePD4lablXUF7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Wed, 08 Dec 2010 18:39:42 -0800 (PST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 9 Dec 2010 13:28:36 +1100
>=20
> > After merging the net tree, today's linux-next build (x86_64 allmodconf=
ig)
> > failed like this:
> >=20
> > drivers/net/can/slcan.c: In function 'slcan_open':
> > drivers/net/can/slcan.c:568: error: dereferencing pointer to incomplete=
 type
>=20
> That's amazing that with all the header files this driver includes,
> powerpc somehow doesn't get the task_struct definition :-)

It was an x86_64 allmodconfig build ... but yeah (I assume you still test
build on Sparc ;-)).

> I'll add the obvious linux/sched.h include to fix this, thanks!

Thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__9_Dec_2010_14_02_07_+1100_ywj4ePD4lablXUF7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNAEavAAoJEDMEi1NhKgbsQswH/293MTG1DbrF+SME8Y/I3NUu
5dtJh9A6B6adgE+4V2GQmVzLEm7IF25jUcsi8yErCmtMyzeSr4BaoXGTZrm15bGc
i2eA+DNF2SgzxxpAOxUYXILy63WYYmPO1tvWx9Ae+gqhdmtRyIBkpZHQZ1DaBE8V
+xyVJnb38L07fTXSR0eiZz/lUxrBUGw+ABaGIDmUfKg9XBWd8k2v7E7h+zqvqnrW
cT9MXNOQqdZOwePgVd93pPMZX69fY18mq/In2+QC3x9gyKtwyssW7SpAfhpiWATE
b4GpDKk+UJha1xnw24JCO6pcumCRvTZKlZFJxatJm+pgyRigzy1gEHE00/U6TMk=
=d43p
-----END PGP SIGNATURE-----

--Signature=_Thu__9_Dec_2010_14_02_07_+1100_ywj4ePD4lablXUF7--
