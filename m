From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Thu, 29 Oct 2009 14:04:51 -0400
Message-ID: <20091029180450.GA31044@gondor.apana.org.au>
References: <1256755214.3153.489.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, mhuth@mvista.com, netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55861 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755071AbZJ2SE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 14:04:56 -0400
Content-Disposition: inline
In-Reply-To: <1256755214.3153.489.camel@linux-1lbu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Chen <schen@mvista.com> wrote:
>
> of the interface that the application is expecting the packet.  It
> appears to bind on interface based on that casual observation.  I'll
> have to study the code in detail to be able to say for sure.

Well if it does bind to the interface then that explains the
failure. And the fix is "if it hurts, don't do it" :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
