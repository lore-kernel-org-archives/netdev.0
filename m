From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: xfrm_algo_clone() allocates too much memory
Date: Tue, 08 Jan 2008 23:40:12 -0800 (PST)
Message-ID: <20080108.234012.181072357.davem@davemloft.net>
References: <E1JCUDY-000791-00@gondolin.me.apana.org.au>
	<478477C7.9030004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbYAIHkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:40:12 -0500
In-Reply-To: <478477C7.9030004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 09 Jan 2008 08:29:11 +0100

Thanks for catching this.

Applied to net-2.6

> +static inline int xfrm_alg_len(struct xfrm_algo *alg)
> +{
> +	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
> +}

That gets emitted as a divide doesn't it :-))))
