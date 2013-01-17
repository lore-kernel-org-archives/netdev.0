From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: fix GRO parameters
Date: Thu, 17 Jan 2013 14:56:41 -0500 (EST)
Message-ID: <20130117.145641.1261296691027201093.davem@davemloft.net>
References: <1358429181-3348-1-git-send-email-yuvalmin@broadcom.com>
	<1358433181.29723.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033Ab3AQT4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 14:56:43 -0500
In-Reply-To: <1358433181.29723.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Jan 2013 06:33:01 -0800

> On Thu, 2013-01-17 at 15:26 +0200, Yuval Mintz wrote:
>> bnx2x does an internal GRO pass but doesn't provide gso_segs, thus
>> breaking qdisc_pkt_len_init() in case ingress qdisc is used.
>> 
>> We store gso_segs in NAPI_GRO_CB(skb)->count, where tcp_gro_complete()
>> expects to find the number of aggregated segments.
>> 
>> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
>> ---
>> This is Eric Dumazet's patch with slight semantic modifications.
>> Eric - Do you want to put your ack or signoff on this patch?
>> 
> 
> Sure, thanks !
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
>> Dave - Please apply this to 'net-next' afterwards.

Applied, thanks.
