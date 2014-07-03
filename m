From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix sparse warning in sk_dst_set()
Date: Wed, 02 Jul 2014 17:03:42 -0700 (PDT)
Message-ID: <20140702.170342.2144083923414489119.davem@davemloft.net>
References: <1404293978.23797.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaGCADm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 20:03:42 -0400
In-Reply-To: <1404293978.23797.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Jul 2014 02:39:38 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> sk_dst_cache has __rcu annotation, so we need a cast to avoid
> following sparse error :
> 
> include/net/sock.h:1774:19: warning: incorrect type in initializer (different address spaces)
> include/net/sock.h:1774:19:    expected struct dst_entry [noderef] <asn:4>*__ret
> include/net/sock.h:1774:19:    got struct dst_entry *dst
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 7f502361531e ("ipv4: irq safe sk_dst_[re]set() and ipv4_sk_update_pmtu() fix")

Applied and I'll make sure this gets passed along with I send 7f502361531e to -stable.

Thanks.
