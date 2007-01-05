From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Fri, 5 Jan 2007 20:38:47 +1100
Message-ID: <20070105093846.GA21000@gondor.apana.org.au>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <20070105063844.GA1675@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dlstevens@us.ibm.com,
	greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1843 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965139AbXAEJjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 04:39:13 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20070105063844.GA1675@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 05, 2007 at 07:38:44AM +0100, Jarek Poplawski wrote:
> 
> I'd only suggest to change "goto out;" to
> "return NULL;" at the end of inetdev_init because
> now RCU is engaged unnecessarily.

I agree.  The RCU assignment should come before the out label.
Can you send a patch?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
