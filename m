From: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Subject: Re: IPsec and Path MTU
Date: Tue, 15 Jun 2004 10:50:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <32703.1087311037@marajade.sandelman.ottawa.on.ca>
References: <20040615124334.GA25164@gondor.apana.org.au>
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: Message from Herbert Xu <herbert@gondor.apana.org.au>
   of "Tue, 15 Jun 2004 22:43:34 +1000." <20040615124334.GA25164@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----


>>>>> "Herbert" == Herbert Xu <herbert@gondor.apana.org.au> writes:
    Herbert> Can someone explain the rationale behind dst->path and
    Herbert> dst_pmtu to me?

    Herbert> As far as I can see it was introduced specifically for
    Herbert> IPsec.  However, it seems to me that it makes no sense
    Herbert> whatsoever in that case.

    Herbert> As it is, the MTU for any peer with an IPsec policy is
    Herbert> determined by the MTU of its dst->path.  But this is wrong
    Herbert> because it assigns a single MTU to all hosts behind an
    Herbert> IPsec gateway, even though their paths may well diverge
    Herbert> beyond the gateway.

    Herbert> So unless I'm missing something, we should get rid of
    Herbert> dst->path and store the MTU in the xfrm dst's directly.

  Not being too familiar with the code, but being very familiar with
pmtu, what you say sounds perfect to me.

  The pmtu WG is considering changing how PMTU is done. You may want to 
look at draft-richardson-ipsec-fragment-XX.txt. This has not yet been
adopted as a WG draft, because nobody is sure which WG should adopt it:-)

- --
]     "Elmo went to the wrong fundraiser" - The Simpson         |  firewalls  [
]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
] mcr@xelerance.com      http://www.sandelman.ottawa.on.ca/mcr/ |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Finger me for keys

iQCVAwUBQM8Mt4qHRg3pndX9AQFocwP+JLy04UB9HaNUGBLvmhW4Nf1+TDtdXZyY
nWJVb1Jl96G3NUDn8nEwe0jfrFpUI8GmY9zPK+l7qonZzHaAym3fP7GWEKz1VKJu
Ckzt76C+qjGVfwgPuYbKyGWDIaUiCIE1AEnJKbYTQMei12im6iGswPYvsOJNy/k/
LU2ABZZnWls=
=bher
-----END PGP SIGNATURE-----
