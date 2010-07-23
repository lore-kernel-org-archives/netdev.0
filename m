From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: macvtap: Limit packet queue length
Date: Fri, 23 Jul 2010 15:58:29 +0800
Message-ID: <20100723075829.GA4606@gondor.apana.org.au>
References: <20100722064157.GA25913@gondor.apana.org.au> <20100722160731.GA30723@gondor.apana.org.au> <20100722.125808.232541418.davem@davemloft.net> <201007230928.09064.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mashirle@us.ibm.com,
	netdev@vger.kernel.org, mwagner@redhat.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54524 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab0GWH6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 03:58:36 -0400
Content-Disposition: inline
In-Reply-To: <201007230928.09064.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 23, 2010 at 09:28:08AM +0200, Arnd Bergmann wrote:
>
> But this is the receive path, not transmit, so a packet coming from an
> external NIC never goes through dev_hard_start_xmit.

In that case skb->sk is probably coming from tuntap, which means
that orphaning the skb is not necessarily a good thing.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
