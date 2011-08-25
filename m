From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipv4: one more case for non-local saddr in
 ICMP
Date: Thu, 25 Aug 2011 10:25:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108250842130.1634@ja.ssi.bg>
References: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg> <20110824.193725.2023779878865246098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47568 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991Ab1HYHTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 03:19:51 -0400
In-Reply-To: <20110824.193725.2023779878865246098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 24 Aug 2011, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Mon, 15 Aug 2011 19:21:23 +0300 (EEST)
> 
> > 	May be there is one more case that we can avoid using
> > non-local source for ICMP errors: xfrm_lookup, num_xfrms = 0 when
> > reverse "Flow passes untransformed". Avoid using the input route
> > if xfrm_lookup returns same dst.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Julian I'm going to defer on this patch unless you think there is
> a real pressing reason to apply it.

	No such reason, it solves a very very rare case.

Regards

--
Julian Anastasov <ja@ssi.bg>
