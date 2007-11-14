From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/24] [IPSEC]: Move x->outer_mode->output out of
 locked section
Date: Tue, 13 Nov 2007 21:39:48 -0800 (PST)
Message-ID: <20071113.213948.164713702.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla1-0001Hb-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45835
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759054AbXKNFjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:39:49 -0500
In-Reply-To: <E1Ipla1-0001Hb-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:29 +0800

> [IPSEC]: Move x->outer_mode->output out of locked section
> 
> RO mode is the only one that requires a locked output function.  So it's
> easier to move the lock into that function rather than requiring everyone
> else to run under the lock.
> 
> In particular, this allows us to move the size check into the output
> function without causing a potential dead-lock should the ICMP error
> somehow hit the same SA on transmission.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
