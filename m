From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Thu, 1 May 2008 22:09:11 +0800
Message-ID: <20080501140911.GB9055@gondor.apana.org.au>
References: <E1JrXMB-00028Q-00@gondolin.me.apana.org.au> <BAY103-DAV8F11938C76B8B9245D864B2DB0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53366 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753039AbYEAOJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 10:09:13 -0400
Content-Disposition: inline
In-Reply-To: <BAY103-DAV8F11938C76B8B9245D864B2DB0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 02:59:42PM +0200, Marco Berizzi wrote:
>
> Yes indeed, this box is in the middle of a very poorly designed
> network: it is the default gateway for lan clients, but it is
> routing back all traffic to another lan box except for ipsec
> traffic.

OK I don't see any rerouting actions in your rule dump.

Is your box SMP or have you enabled preemption? Just trying to
eliminate the case of another thread zapping skb->dst.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
