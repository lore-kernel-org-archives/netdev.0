From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered
Date: Sun, 23 Apr 2006 15:49:03 +1000
Message-ID: <20060423054903.GA14032@gondor.apana.org.au>
References: <20060421102757.45d26db0@localhost.localdomain> <E1FXXNS-0003dJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: p_gortmaker@yahoo.com, netdev@vger.kernel.org, tomri@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:30728 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751307AbWDWFtL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 01:49:11 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <E1FXXNS-0003dJ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 23, 2006 at 03:43:22PM +1000, Herbert Xu wrote:
> 
> Can you please put some printks in to find out if
> 
> 1) skb_padto is being called.
> 2) Is the input to skb_padto aligned?

I'd also help if you could print out the contents of the packet itself.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
