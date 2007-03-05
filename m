From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH/RFC] Use of uninitialized data in udp_recvmsg().
Date: Tue, 6 Mar 2007 10:34:49 +1100
Message-ID: <20070305233449.GA24159@gondor.apana.org.au>
References: <E1HOLBe-000660-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0703051257520.27979@jchow-amax.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jim Chow <jchow@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4643 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752216AbXCEXe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 18:34:58 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703051257520.27979@jchow-amax.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 01:01:16PM -0800, Jim Chow wrote:
> On Tue, 6 Mar 2007, Herbert Xu wrote:
> > msg_flags [...] its initial value is not used.
> 
> That's not true.  Please see my post.
> 
> Specifically, at linux-2.6.20.1/net/ipv4/udp.c:843, it seems that 
> udp_recvmsg() can randomly ignore whether the HW has computed a checksum 
> and compute it in SW redundantly.

Sorry, you're right.  This bug has been there for years.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
