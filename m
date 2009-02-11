From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Wed, 11 Feb 2009 23:50:38 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0902112334570.17583@blackhole.kfki.hu>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu> <20090211201908.GA25398@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090211201908.GA25398@rere.qmqm.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2009, Micha? Miros?aw wrote:

> On Wed, Feb 11, 2009 at 11:19:20AM +0100, Jozsef Kadlecsik wrote:
> >  /* The golden ration: an arbitrary value */
> > -#define JHASH_GOLDEN_RATIO	0x9e3779b9
> > +#define JHASH_GOLDEN_RATIO	0xdeadbeef
> 
> I have a stupid question: if this is arbitrary value, then why not
> just get rid of it (IOW use zero as it's used in addition)?

lookup3() is a quite generic hash function and it supports 0-byte strings 
as input keys too. If the input key is a 0-byte string and the arbitrary 
value is zero, then the hash value simply equal to the initval. In order 
to avoid that case, the arbitrary value must be nonzero.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
