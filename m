From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Remove 'unlikely' qualifier in
 skb_steal_sock()
Date: Mon, 25 Jun 2012 16:08:54 -0700 (PDT)
Message-ID: <20120625.160854.1727067247321005209.davem@davemloft.net>
References: <1340578987-2495-1-git-send-email-subramanian.vijay@gmail.com>
	<1340604577.23933.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab2FYXIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:08:55 -0400
In-Reply-To: <1340604577.23933.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Jun 2012 08:09:37 +0200

> On Sun, 2012-06-24 at 16:03 -0700, Vijay Subramanian wrote:
>> With early demux enabled by default for TCP flows, there is high chance that
>> skb->sk will be non-null. 'unlikely()' was removed from __inet_lookup_skb() but
>> maybe it can be removed from skb_steal_sock() as well.
>> 
>> Note: skb_steal_sock() is also called by __inet6_lookup_skb() and
>> __udp4_lib_lookup_skb() but they are protected by their own 'unlikely' calls.
>> 
>> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
