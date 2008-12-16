From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] net: Add frag_list support to GSO
Date: Mon, 15 Dec 2008 23:30:59 -0800 (PST)
Message-ID: <20081215.233059.01751593.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPc-0003YL-7r@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750721AbYLPHa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:30:57 -0500
In-Reply-To: <E1LBJPc-0003YL-7r@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Dec 2008 12:35:20 +1100

> net: Add frag_list support to GSO
> 
> This patch allows GSO to handle frag_list in a limited way for the
> purposes of allowing packets merged by GRO to be refragmented on
> output.
> 
> Most hardware won't (and aren't expected to) support handling GRO
> frag_list packets directly.  Therefore we will perform GSO in
> software for those cases.
> 
> However, for drivers that can support it (such as virtual NICs) we
> may not have to segment the packets at all.
> 
> Whether the added overhead of GRO/GSO is worthwhile for bridges
> and routers when weighed against the benefit of potentially
> increasing the MTU within the host is still an open question.
> However, for the case of host nodes this is undoubtedly a win.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
