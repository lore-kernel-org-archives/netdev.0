From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Tue, 07 Oct 2014 13:22:44 -0400 (EDT)
Message-ID: <20141007.132244.460509534988004588.davem@davemloft.net>
References: <1412559515.11091.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141006.175015.2075737681876306575.davem@davemloft.net>
	<1412633126.11091.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbaJGRWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:22:47 -0400
In-Reply-To: <1412633126.11091.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Oct 2014 15:05:26 -0700

> We have a loop over team/bonding members, where we do :
> 
> dst_release_flag &= slave->dev->priv_flags;
> 
> So at the end of the loop, we check if any one of the member had one of
> the bit cleared.
> 
> if dst_release_flags has both bits set, then we are set and we allow the
> IFF_XMIT_DST_RELEASE being set on the master.

Oh I see, I mis-read the patch thinking dst_release_flags was a new variable
when in fact it's an existing one.

Patch applied, thanks Eric.
