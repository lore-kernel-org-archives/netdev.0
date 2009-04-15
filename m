From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Lguest] [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 16:36:10 +0800
Message-ID: <20090415083610.GA8579@gondor.apana.org.au>
References: <200903271022.38244.rusty@rustcorp.com.au> <1238709324.5823.8.camel@odie.local> <1239043798.27826.93.camel@zetabook> <200904081021.39877.rusty@rustcorp.com.au> <1239224319.17844.16.camel@zetabook> <49DDE91A.8060603@trash.net> <49DDF614.1060909@trash.net> <m1bpr6hqrm.fsf@fess.ebiederm.org> <49E47976.8020005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Matias Zabaljauregui <zabaljauregui@gmail.com>, odie@cs.aau.dk,
	Rusty Russell <rusty@rustcorp.com.au>, lguest@ozlabs.org,
	virtualization@lists.osdl.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43156 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759338AbZDOIgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 04:36:48 -0400
Content-Disposition: inline
In-Reply-To: <49E47976.8020005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 01:54:30PM +0200, Patrick McHardy wrote:
>
> I see. How about this patch instead? It moves the sk_sleep assignment
> to tun_attach, after the permission checks took place.

Thanks for pointing out this gaping hole in my patch.  I think
it may be better to remove read_wait altogether and just use
socket.wait in tun_struct.

Let me whip up a patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
