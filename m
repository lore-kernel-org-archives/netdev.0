From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: speedup neigh_resolve_output()
Date: Mon, 11 Oct 2010 13:01:28 -0700 (PDT)
Message-ID: <20101011.130128.245392712.davem@davemloft.net>
References: <1286484247.3745.91.camel@edumazet-laptop>
	<20101011.121609.246536311.davem@davemloft.net>
	<1286826361.3218.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43699
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755491Ab0JKUBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 16:01:06 -0400
In-Reply-To: <1286826361.3218.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 21:46:01 +0200

> Hmm, we would need a neigh->ha pointer to some struct, with rcu
> protection. It adds a dereference in hot path. I believe this seqlock
> (only for pathological cases, where dst are used for few packets) should
> be fine.

Good point.

Ok, assuming it passes build testing I'll push this seqlock
patch to net-next-2.6

Thanks!

