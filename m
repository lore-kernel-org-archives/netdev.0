From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] [IPSEC]: Unexport xfrm_replay_notify
Date: Mon, 08 Oct 2007 17:26:47 -0700 (PDT)
Message-ID: <20071008.172647.106749542.davem@davemloft.net>
References: <20071008112818.GA3010@gondor.apana.org.au>
	<E1Ieqnv-0000oK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751836AbXJIA0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 20:26:48 -0400
In-Reply-To: <E1Ieqnv-0000oK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 08 Oct 2007 19:29:43 +0800

> [IPSEC]: Unexport xfrm_replay_notify
> 
> Now that the only callers of xfrm_replay_notify are in xfrm, we can remove
> the export.
> 
> This patch also removes xfrm_aevent_doreplay since it's now called in just
> one spot.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
