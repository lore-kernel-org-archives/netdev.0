From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 8 Apr 2010 23:07:32 +0800
Message-ID: <20100408150732.GA25950@gondor.apana.org.au>
References: <20100408.035049.177640912.davem@davemloft.net> <20100408114738.GA23329@gondor.apana.org.au> <20100408142722.GA25392@gondor.apana.org.au> <1270737440.1872.93.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:34380 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751755Ab0DHPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 11:07:40 -0400
Content-Disposition: inline
In-Reply-To: <1270737440.1872.93.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 04:37:20PM +0200, Maxime Bizon wrote:
>
> You can't close the socket while bound since you can receive DHCPINFORM
> anytime.

Right, as long as you don't use an AF_PACKET socket most of the
time it should be fine.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
