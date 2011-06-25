From: David Miller <davem@davemloft.net>
Subject: Re: unintended ipv4 broadcast policy change
Date: Fri, 24 Jun 2011 17:28:32 -0700 (PDT)
Message-ID: <20110624.172832.2148913323950089821.davem@davemloft.net>
References: <20110624100121.63bbc93a@nehalam.ftrdhcpuser.net>
	<20110624.125406.600608999605842473.davem@davemloft.net>
	<20110625002724.GA12880@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab1FYA2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 20:28:37 -0400
In-Reply-To: <20110625002724.GA12880@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Sat, 25 Jun 2011 08:27:24 +0800

> On Fri, Jun 24, 2011 at 12:54:06PM -0700, David Miller wrote:
>> They must be because this is capturing ETH_P_ALL with type SOCK_PACKET
>> which means receive all packets unconditionally.
> 
> sock_queue_rcv_skb calls sk_filter, strange but true :)

Aha, that explains everything :)
