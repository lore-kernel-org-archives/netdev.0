From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: nf_nat_sip: c= is optional for session
Date: Mon, 21 Jul 2008 16:11:40 +0200
Message-ID: <4884991C.3020503@trash.net>
References: <20080721132513.GA11162@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38495 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbYGUOLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 10:11:41 -0400
In-Reply-To: <20080721132513.GA11162@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Hi Patrick:
> 
> My phone stopped working after my router was upgraded to 2.6.26.
> This patch makes it work again.
> 
> netfilter: nf_nat_sip: c= is optional for session
> 
> According to RFC2327, the connection information is optional
> in the session description since it can be specified in the
> media description instead.
> 
> My provider does exactly that and does not provide any connection
> information in the session description.  As a result the new
> kernel drops all invite responses.
> 
> This patch makes it optional as documented.

Applied, thanks. I'll also push it -stable.
