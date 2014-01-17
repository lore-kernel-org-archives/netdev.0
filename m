From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] net: Check skb->rxhash in gro_receive
Date: Thu, 16 Jan 2014 16:23:41 -0800 (PST)
Message-ID: <20140116.162341.93513484467750793.davem@davemloft.net>
References: <alpine.DEB.2.02.1401150853400.14933@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaAQAXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:23:41 -0500
In-Reply-To: <alpine.DEB.2.02.1401150853400.14933@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 15 Jan 2014 08:58:06 -0800 (PST)

> When initializing a gro_list for a packet, first check the rxhash of
> the incoming skb against that of the skb's in the list. This should be
> a very strong inidicator of whether the flow is going to be matched,
> and potentially allows a lot of other checks to be short circuited.
> Use skb_hash_raw so that we don't force the hash to be calculated.
> 
> Tested by running netperf 200 TCP_STREAMs between two machines with
> GRO, HW rxhash, and 1G. Saw no performance degration, slight reduction
> of time in dev_gro_receive.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
