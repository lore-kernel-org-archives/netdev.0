From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bonding: use l4 hash if available
Date: Thu, 17 Sep 2015 21:01:32 -0700 (PDT)
Message-ID: <20150917.210132.133960738718544060.davem@davemloft.net>
References: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbbIREBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:01:33 -0400
In-Reply-To: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Sep 2015 15:24:28 -0700

> +	if (bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP34 &&
> +	    skb->l4_hash)
> +			return skb->hash;

Applied, with the indentation of the return statement fixed up.
:-)
