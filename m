From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Sat, 11 Aug 2007 00:38:35 -0400
Message-ID: <7943.1186807115@turing-police.cc.vt.edu>
References: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au> <442f95ba19f8622ce04cf0334f34be11@kernel.crashing.org> <20070811000029.GA12779@gondor.apana.org.au>
            <ef7e94b08a6515d33039d187e04db5db@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1186807115_3018P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	paulmck@linux.vnet.ibm.com, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	csnook@redhat.com, rpjday@mindspring.com, netdev@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753494AbXHKEkg@vger.kernel.org>
In-Reply-To: Your message of "Sat, 11 Aug 2007 02:38:40 +0200."
             <ef7e94b08a6515d33039d187e04db5db@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1186807115_3018P
Content-Type: text/plain; charset=us-ascii

On Sat, 11 Aug 2007 02:38:40 +0200, Segher Boessenkool said:
> >> That means GCC cannot compile Linux; it already optimises
> >> some accesses to scalars to smaller accesses when it knows
> >> it is allowed to.  Not often though, since it hardly ever
> >> helps in the cost model it employs.
> >
> > Please give an example code snippet + gcc version + arch
> > to back this up.
> 
> 	unsigned char f(unsigned long *p)
> 	{
> 	        return *p & 1;
> 	}

Not really valid, because it's still able to do one atomic access to
compute the result.

Now, if you had found an example where it converts a 32-bit atomic access into
2 separate 16-bit accesses that weren't atomic as a whole....

--==_Exmh_1186807115_3018P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGvT1LcC3lWbTT17ARAmccAKCRd2ZxCdpo0ruAOJZXkpds4qazcwCff1OA
WRSvt/dpaznIWvvdf7+Q/1o=
=uesa
-----END PGP SIGNATURE-----

--==_Exmh_1186807115_3018P--
