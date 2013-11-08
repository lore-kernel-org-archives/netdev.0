From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 next-next 0/3] move pskb_put
Date: Thu, 07 Nov 2013 19:29:38 -0500 (EST)
Message-ID: <20131107.192938.841488052158954645.davem@davemloft.net>
References: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	dmitry.tarnyagin@lockless.no, bhutchings@solarflare.com,
	edumazet@google.com, netdev@vger.kernel.org
To: mathias.krause@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752Ab3KHA3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:29:40 -0500
In-Reply-To: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <mathias.krause@secunet.com>
Date: Thu,  7 Nov 2013 14:18:23 +0100

> This series moves pskb_put() to the core code, making the code
> duplication in caif obsolete (patches 1 and 2).
> Patch 3 fixes a few kernel-doc issues.
> 
> v2 of this series does no longer contain the skb_cow_data() patch and
> therefore no performance improvements for IPsec. The change is still
> under discussion, but otherwise independent from the above changes.
> 
> Please apply!

Series applied, thanks!
