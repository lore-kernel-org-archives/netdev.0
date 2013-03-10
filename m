From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] tunnel: use iptunnel_xmit() again
Date: Sun, 10 Mar 2013 03:05:56 -0400 (EDT)
Message-ID: <20130310.030556.572539791582239317.davem@davemloft.net>
References: <1362883119-4099-1-git-send-email-xiyou.wangcong@gmail.com>
	<1362889787.4051.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	pshelar@nicira.com, stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab3CJHFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 03:05:52 -0400
In-Reply-To: <1362889787.4051.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 10 Mar 2013 05:29:47 +0100

> On Sun, 2013-03-10 at 10:38 +0800, Cong Wang wrote:
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>> 
>> With recent patches from Pravin, most tunnels can't use iptunnel_xmit()
>> any more, due to ip_select_ident() and skb->ip_summed. But we can just
>> move these operations out of iptunnel_xmit(), so that tunnels can
>> use it again.
>> 
>> This by the way fixes a bug in vxlan (missing nf_reset()) for net-next.
>> 
>> Cc: Pravin B Shelar <pshelar@nicira.com>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> 
>> ---
> 
> missing diffstat
> 
> otherwise, patch looks good to me
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
