From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 18:51:53 -0800
Message-ID: <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	 <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
	 <20131107.170651.1819930710384730745.davem@davemloft.net>
	 <20131108021758.GA13467@gondor.apana.org.au>
	 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:51657 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab3KHCwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:52:34 -0500
Received: by mail-ie0-f180.google.com with SMTP id e14so2286627iej.25
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 18:52:33 -0800 (PST)
In-Reply-To: <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 18:42 -0800, Eric Dumazet wrote:

> A normal TSO packets with 16 MSS setups a ~17 DMA descriptors,
> while GSO requires 2 DMA descriptors per MSS, plus a lot of overhead
> in sk_buff allocation/deallocation.

Not mentioning fact that a 64KB packet is adding latencies, since high
prio packets have to wait the whole preceding 64KB packet has left the
host.
