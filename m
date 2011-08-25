From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: one more case for non-local saddr in
 ICMP
Date: Wed, 24 Aug 2011 19:37:25 -0700 (PDT)
Message-ID: <20110824.193725.2023779878865246098.davem@davemloft.net>
References: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab1HYChi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 22:37:38 -0400
In-Reply-To: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 15 Aug 2011 19:21:23 +0300 (EEST)

> 	May be there is one more case that we can avoid using
> non-local source for ICMP errors: xfrm_lookup, num_xfrms = 0 when
> reverse "Flow passes untransformed". Avoid using the input route
> if xfrm_lookup returns same dst.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Julian I'm going to defer on this patch unless you think there is
a real pressing reason to apply it.

Thanks.
