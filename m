From: Valdis.Kletnieks@vt.edu
Subject: Re: linux-next Problems with VPN tunnel - no packets sent
Date: Wed, 03 Dec 2014 09:51:20 -0500
Message-ID: <7763.1417618280@turing-police.cc.vt.edu>
References: <17929.1417552899@turing-police.cc.vt.edu>
            <1417576339.19959.0@smtp.corp.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1417618280_7177P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Wed, 03 Dec 2014 03:20:19 +0008."
             <1417576339.19959.0@smtp.corp.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1417618280_7177P
Content-Type: text/plain; charset=us-ascii

On Wed, 03 Dec 2014 03:20:19 +0008, Jason Wang said:

> > Still broken in next-20141201, and bisection fingers this commit:
> >
> > commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Fri Nov 7 21:22:23 2014 +0800
> >
> >     tun: Use iovec iterators

> > What's the best way to proceed?
>
> See another fixes from Herbert, it probably fixes your issue:
>
> http://marc.info/?l=linux-netdev&m=141734182302021&w=2

Unfortunately, I'm still seeing the same behavior with that patch
applied to next-20141201....


--==_Exmh_1417618280_7177P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVH8jaAdmEQWDXROgAQJW0g/+MHfjfND4Q6yMqjZuKgLMT28bkumu1d6s
nuL9xlBTkX/uXBtKVlki5+ndfGPqitBnFvWG/HoxKMQzarpYEY89j/4s+iAWt/fl
MPay2LEoFsJPfoCMR1VfXZ9uEvEDk1Wx+StitBcdCqFCbeS9KmvlJk5Qmw92VE5Y
MElHT7kEcQRwTXRYqfTQyR+orf5Tnc4CE9k5rXWfXiC/owaXQ8771M1qOuvldRAX
Bogwc9raddYwvJRpJe2BDMdlfmptirnDcRCNUxe1yUoA5YEK0VCR0blQ2KT8/XlE
uKJu/Zwx7WTb/Ww5Mr1Nk2J2agyB1oJ06YR2J87EF37eWwOJOOXoNcHKUoScxZSZ
u//A5R5h9EqY+kCTKqzq+h9T3uMyAQ3HUKHZYKnKMtPd14XTyVUMZaCzRFDfI9FE
qqC5atdaHJvKiLE/R+JACvscxX+gf1rmCkXx/IA+woP0/S1/e/yy623DXZ70nlbV
dnrBSrO5z/VJPVOpIuvQhnN9p6HBBBizbwMfTOl/GdU7+2SLzrtDE0eggeErPvky
oep3vM6Z+BCdvBJVdscKkA7/BLM+kgSq9IBIeOPRUdfSqhq1yMLGW2cMBm14rK1g
uRXvar+VnCFGtp3reiaAPNfdhTELhW3zepqZHlWa3HvH0zabP7e1LMoC+gre0EuT
dWgTzpCzHTc=
=Y47g
-----END PGP SIGNATURE-----

--==_Exmh_1417618280_7177P--
