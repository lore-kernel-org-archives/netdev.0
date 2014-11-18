From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] icmp: Remove some spurious dropped packet
 profile hits from the ICMP path
Date: Tue, 18 Nov 2014 15:56:09 -0500 (EST)
Message-ID: <20141118.155609.1055967220928366239.davem@davemloft.net>
References: <20141117220429.B000D29003AD@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932541AbaKRU4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:56:11 -0500
In-Reply-To: <20141117220429.B000D29003AD@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Mon, 17 Nov 2014 14:04:29 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> If icmp_rcv() has successfully processed the incoming ICMP datagram, we
> should use consume_skb() rather than kfree_skb() because a hit on the likes
> of perf -e skb:kfree_skb is not called-for.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

This looks better, applied, thanks Rick.
