From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 8 Apr 2010 22:27:22 +0800
Message-ID: <20100408142722.GA25392@gondor.apana.org.au>
References: <20100408.035049.177640912.davem@davemloft.net> <20100408114738.GA23329@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:44834 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751755Ab0DHO10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 10:27:26 -0400
Content-Disposition: inline
In-Reply-To: <20100408114738.GA23329@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 07:47:38PM +0800, Herbert Xu wrote:
> 
> The main problem is that it needs to be able to receive packets
> destined to an address which is not yet a local address.  IOW,
> it needs to be able to bypass the routing table and receive
> non-local traffic.

Oh and if anybody is doing any user-space hacking, this is what you
could do: AF_PACKET is only necessary when you're waiting for a
response from the server.  So you could close the socket after a
lease has been acquired, and reopen it the next time you need
to communicate with a server.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
