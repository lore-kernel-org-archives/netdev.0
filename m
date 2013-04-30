From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: RE: [PATCH 04/18] netfilter: ipset: Unified bitmap type generation
Date: Tue, 30 Apr 2013 11:19:31 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1304301058540.20765@blackhole.kfki.hu>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org> <1367259744-8922-5-git-send-email-pablo@netfilter.org> <AE90C24D6B3A694183C094C60CF0A2F6026B720F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp0.kfki.hu ([148.6.0.25]:36204 "EHLO smtp0.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759514Ab3D3JTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 05:19:34 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B720F@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Apr 2013, David Laight wrote:

> > +++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
> > @@ -0,0 +1,265 @@
> ...
> > +#define CONCAT(a, b)		a##b
> > +#define TOKEN(a,b)		CONCAT(a, b)
> > +
> > +#define mtype_do_test		TOKEN(MTYPE, _do_test)
> > +#define mtype_gc_test		TOKEN(MTYPE, _gc_test)
> ...
> > +#define mtype			MTYPE
> 
> I'm not entirely sure what is being achieved by the above.
> Either there ought to be a comment about what MTYPE might
> be set to, or it is all pointless.

mtype is defined in order to SHOUT less in the code later.
 
> In any case names like CONCAT() and TOKEN() are likely
> to be double definitions.
>
> A similar namespace issue arises with REVISION_MIN/MAX.

I'll send a patch with more speficic names.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
