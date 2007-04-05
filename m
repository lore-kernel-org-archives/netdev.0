From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec PMTUD problem
Date: Thu, 5 Apr 2007 22:12:56 +1000
Message-ID: <20070405121256.GD10972@gondor.apana.org.au>
References: <46110ED1.9070209@trash.net> <20070403095510.GA7754@gondor.apana.org.au> <46128187.4090601@trash.net> <20070405120425.GC10972@gondor.apana.org.au> <4614E6F0.10905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4416 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1766990AbXDEN4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 09:56:15 -0400
Content-Disposition: inline
In-Reply-To: <4614E6F0.10905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 05, 2007 at 02:09:20PM +0200, Patrick McHardy wrote:
>
> > One possible solution is to not send MTU errors to ourselves since
> > we it wouldn't give us any new information.  We'd need to audit the
> > users of icmp_send to make sure that there isn't a legitimate case
> > where we'd want to do that.
> 
> One such case is delivery of errors to sockets. We'd need to make
> sure the errors are delivered some other way.

Alternatively we can still send the ICMP error but avoid a PMTU
update if we received it from ourselves.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
