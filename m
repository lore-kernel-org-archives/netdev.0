From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tx scalability works : trans_start
Date: Mon, 18 May 2009 15:11:52 -0700 (PDT)
Message-ID: <20090518.151152.76033192.davem@davemloft.net>
References: <4A09D269.60703@cosmosbay.com>
	<20090517.205710.137526481.davem@davemloft.net>
	<4A110C7B.4020407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35858
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754362AbZERWLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:11:54 -0400
In-Reply-To: <4A110C7B.4020407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 18 May 2009 09:21:31 +0200

> Indeed we can do this factorization, just have to take care of not
> adding a new cache line miss on loopback device, as this one doesnt
> touch dev->trans_start.

If you want to test IFF_LOOPBACK or similar, I can accept that.
Or it can be some NETIF_F_* flag.

> What do you think ? (following patch as RFC only, not even booted)

This patch looks fine to me.
