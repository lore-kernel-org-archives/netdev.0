From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [IPV6]: Do not set IF_READY if device is down
Date: Wed, 28 Mar 2007 01:33:30 +0100
Message-ID: <1175042010.3277.68.camel@pmac.infradead.org>
References: <200703080359.l283xo6S012573@hera.kernel.org>
	 <1175003838.3277.41.camel@pmac.infradead.org>
	 <20070327213032.GA30935@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41816 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934268AbXC1Adn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 20:33:43 -0400
In-Reply-To: <20070327213032.GA30935@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-03-28 at 07:30 +1000, Herbert Xu wrote:
> Sorry, that patch is indeed broken.  We do need to set IF_READY in
> the case where all addresses were deleted (including the link-local)
> and then recreated.  The IPv6 device will be destroyed and recreated
> too in that case. 

Your new patch fixes the problem for me, at least with my test script.
Thanks.

-- 
dwmw2

