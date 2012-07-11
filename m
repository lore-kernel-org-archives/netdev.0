From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Tue, 10 Jul 2012 23:13:36 -0700 (PDT)
Message-ID: <20120710.231336.186224288666405286.davem@davemloft.net>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
	<1341980090.13724.43.camel@joe2Laptop>
	<1341983157.3265.6792.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755672Ab2GKGNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:13:37 -0400
In-Reply-To: <1341983157.3265.6792.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Jul 2012 07:05:57 +0200

> [PATCH net-next v2]  ipv6: optimize ipv6 addresses compares
> 
> On 64 bit arches having efficient unaligned accesses (eg x86_64) we can
> use long words to reduce number of instructions for free.
> 
> Joe Perches suggested to change ipv6_masked_addr_cmp() to return a bool
> instead of 'int', to make sure ipv6_masked_addr_cmp() cannot be used
> in a sorting function.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, will apply, thanks.
