From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Mon, 27 Apr 2009 05:45:05 -0700 (PDT)
Message-ID: <20090427.054505.03426047.davem@davemloft.net>
References: <20090424054557.GA24575@gondor.apana.org.au>
	<49F1E5C8.7010303@myri.com>
	<20090427080501.GA21433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, brice@myri.com, sgruszka@redhat.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755450AbZD0MpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 08:45:11 -0400
In-Reply-To: <20090427080501.GA21433@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 27 Apr 2009 16:05:01 +0800

> gro: Fix handling of headers that extend over the tail
> 
> The skb_gro_* code fails to handle the case where a header starts
> in the linear area but ends in the frags area.  Since the goal
> of skb_gro_* is to optimise the case of completely non-linear
> packets, we can simply bail out if we have anything in the linear
> area.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
