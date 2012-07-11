From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Wed, 11 Jul 2012 11:05:12 +0300
Message-ID: <4FFD33B8.5010604@mellanox.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>  <1341922569-4118-4-git-send-email-ogerlitz@mellanox.com> <1341923180.3265.5005.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:57607 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752631Ab2GKIGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:06:32 -0400
In-Reply-To: <1341923180.3265.5005.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/10/2012 3:26 PM, Eric Dumazet wrote:
> On Tue, 2012-07-10 at 15:16 +0300, Or Gerlitz wrote:
>> The IPoIB code checks the VIF private flag on the RX path, and accoriding
>> to the value of the flag prepares the skb CB data, etc.
>>
>
> skb->cb[] can be destroyed in netif_receive_skb() / __netif_receive_skb()
>
> #ifdef CONFIG_NET_CLS_ACT
> 	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
> 	...
> #endif

Eric,

Can you elaborate a little further? we're not sure to see where 
skb->cb[] is touched on the flow
you pointed to.

Or.
