From: Paul Mackerras <paulus@samba.org>
Subject: Re: IPSec kernel oops on ppc64
Date: Thu, 31 Aug 2006 14:25:46 +1000
Message-ID: <17654.25802.380698.831529@cargo.ozlabs.ibm.com>
References: <200608301636.k7UGaQY5002569@faith.austin.ibm.com>
	<20060831015942.GA27423@gondor.apana.org.au>
	<17654.21983.691176.397891@cargo.ozlabs.ibm.com>
	<20060831035346.GA28306@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@vger.kernel.org, anton@au1.ibm.com,
	linuxppc-dev@ozlabs.org, gcwilson@us.ibm.com,
	Joy Latten <latten@austin.ibm.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46813 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1750962AbWHaEZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 00:25:51 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060831035346.GA28306@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> BTW, did you see the "cmpldi r1,..." stuff in the code?  That's a typo,
> right?

Yes it is a typo, but fixing it is lower priority since both r1 and
cr1 equal 1.

Paul.

