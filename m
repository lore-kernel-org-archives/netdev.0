From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ipv6: addrlabel: avoid dirtying
 ip6addrlbl_entry
Date: Mon, 09 Oct 2017 10:47:44 -0700 (PDT)
Message-ID: <20171009.104744.1618465540036605161.davem@davemloft.net>
References: <20171009165225.7008-1-edumazet@google.com>
        <20171009174417.gpfghoxctgksdzaz@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754468AbdJIRrp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:47:45 -0400
In-Reply-To: <20171009174417.gpfghoxctgksdzaz@kafai-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 9 Oct 2017 10:44:17 -0700

> On Mon, Oct 09, 2017 at 04:52:23PM +0000, Eric Dumazet wrote:
>> The refcount on ip6addrlbl_entry is only used to make sure ip6addrlbl_entry
>> does not disappear while ip6addrlbl_get() is allocating an skb.
>> 
>> We can instead allocate skb first, then use RCU, so that we no longer need
>> to refcount these structures.
> Acked-by: Martin KaFai Lau <kafai@fb.com>

Series applied, thanks everyone.
