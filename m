From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 04:09:33 -0700 (PDT)
Message-ID: <20120620.040933.1704761178329634866.davem@davemloft.net>
References: <20120619.231412.1236237191660427779.davem@davemloft.net>
	<20120620.031543.1511134879638711616.davem@davemloft.net>
	<1340190206.4604.862.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923Ab2FTLJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 07:09:36 -0400
In-Reply-To: <1340190206.4604.862.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 13:03:26 +0200

> I am not sure we need the skb_dst(skb) test here, it should be NULL
> anyway in GRO layer ? (loopback device don't use GRO ;) )

Thanks, I was too lazy to check this and just assumed that a non-NULL
skb_dst(skb) was a very real possibility.
