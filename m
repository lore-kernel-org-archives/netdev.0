From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Mon, 15 Dec 2008 23:40:32 -0800 (PST)
Message-ID: <20081215.234032.141150303.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753110AbYLPHkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:40:32 -0500
In-Reply-To: <E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Dec 2008 12:35:21 +1100

> net: Add Generic Receive Offload infrastructure
 ...
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, although there were some merge issues to deal with
wrt. Neil's netpoll race fix.  That wasn't too bad.

Also:

> +int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
> +{
> +	struct sk_buff **pp;

I made this 'pp' variable get initialized to NULL because
gcc is stupid and thinks this might get used uninitialized.
