From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 18:51:16 -0400
Message-ID: <28709.1187736676@turing-police.cc.vt.edu>
References: <20070818000913.GA25585@gondor.apana.org.au> <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com> <46C997B1.1010800@redhat.com> <417ebba299a7ad3c4b7a31c4f860a814@kernel.crashing.org> <20070820224859.GA16162@flint.arm.linux.org.uk> <2bdb04581125f22122f1d230e991ea92@kernel.crashing.org> <20070821070555.GA32036@flint.arm.linux.org.uk> <18122.45437.807239.395869@cargo.ozlabs.ibm.com> <33412cad5894a9cbdc85482db5e9a0a0@kernel.crashing.org>
            <20070821161643.GA7574@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1187736676_2990P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>,
	Christoph Lameter <clameter@sgi.com>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, akpm@linux-foundation.org,
	rpjday@mindspring.com, Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	satyam@infradead.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:37548 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbXHUWxq (ORCPT
	<RFC822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 18:53:46 -0400
In-Reply-To: Your message of "Tue, 21 Aug 2007 09:16:43 PDT."
             <20070821161643.GA7574@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1187736676_2990P
Content-Type: text/plain; charset=us-ascii

On Tue, 21 Aug 2007 09:16:43 PDT, "Paul E. McKenney" said:

> I agree that instant gratification is hard to come by when synching
> up compiler and kernel versions.  Nonetheless, it should be possible
> to create APIs that are are conditioned on the compiler version.

We've tried that, sort of.  See the mess surrounding the whole
extern/static/inline/__whatever boondogle, which seems to have
changed semantics in every single gcc release since 2.95 or so.

And recently mention was made that gcc4.4 will have *new* semantics
in this area. Yee. Hah.






--==_Exmh_1187736676_2990P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGy2xkcC3lWbTT17ARAhlSAKDNaADYU7Xmy2nbLFMctFnTdjkAeACfSEbb
OM4uGVrXvWzztHDShpVKgVU=
=U3M2
-----END PGP SIGNATURE-----

--==_Exmh_1187736676_2990P--
