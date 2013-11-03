From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 18:23:32 -0500 (EST)
Message-ID: <20131103.182332.1995863954220787224.davem@davemloft.net>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131103122824.GA17394@gondor.apana.org.au>
	<1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724Ab3KCXXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 18:23:34 -0500
In-Reply-To: <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 03 Nov 2013 08:28:24 -0800

> 1) Because we should not call skb_segment() at all on a router ?

Eric, disagreement with this very thing is the basis for the entire
thread you have engaged with Herbert Xu about.  It's as if you've
ignored everything discussed there, please don't do this.
