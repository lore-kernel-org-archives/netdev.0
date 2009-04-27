From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Mon, 27 Apr 2009 05:45:14 -0700 (PDT)
Message-ID: <20090427.054514.73558811.davem@davemloft.net>
References: <49F1E5C8.7010303@myri.com>
	<20090427080501.GA21433@gondor.apana.org.au>
	<20090427080735.GA21493@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, brice@myri.com, sgruszka@redhat.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756218AbZD0MpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 08:45:21 -0400
In-Reply-To: <20090427080735.GA21493@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 27 Apr 2009 16:07:35 +0800

> gro: Fix COMPLETE checksum handling
> 
> On a brand new GRO skb, we cannot call ip_hdr since the header
> may lie in the non-linear area.  This patch adds the helper
> skb_gro_network_header to handle this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
