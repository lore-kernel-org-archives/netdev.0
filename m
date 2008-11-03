From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] udp: Fix the SNMP counter of UDP_MIB_INDATAGRAMS
Date: Mon, 03 Nov 2008 10:38:39 +0800
Message-ID: <490E642F.8080509@cn.fujitsu.com>
References: <490C1CA7.3070201@cn.fujitsu.com> <20081101.213529.60503932.davem@davemloft.net> <490E57FE.804@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60674 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754150AbYKCCmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 21:42:53 -0500
In-Reply-To: <490E57FE.804@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philip Craig wrote:
> David Miller wrote:
>   
>> From: Wei Yongjun <yjwei@cn.fujitsu.com>
>> Date: Sat, 01 Nov 2008 17:08:55 +0800
>>
>>     
>>> @@ -158,6 +159,8 @@ try_again:
>>>  	else if (copied < ulen)
>>>  		msg->msg_flags |= MSG_TRUNC;
>>>  +	is_udp4 = (skb->protocol == htons(ETH_P_IP));
>>> +
>>>  	/*
>>>  	 * If checksum is needed at all, try to do it while copying the
>>>  	 * data.  If the data is truncated, or if we only want a partial
>>>       
>>  ...
>>     
>>>  	sock_recv_timestamp(msg, sk, skb);
>>>  @@ -196,7 +204,7 @@ try_again:
>>>  		sin6->sin6_flowinfo = 0;
>>>  		sin6->sin6_scope_id = 0;
>>>  -		if (skb->protocol == htons(ETH_P_IP))
>>> +		if (is_udp4)
>>>  			ipv6_addr_set(&sin6->sin6_addr, 0, 0,
>>>       
>> This patch is corrupted in ways I thought I would never see in my
>> entire life.  Congratulations!
>>     
>
> The patch looked okay to me, but judging by the bits you quoted,
> the format=flowed is causing the problem.
>   

It is also ok at http://patchwork.ozlabs.org/patch/6776/ and 
http://marc.info/?l=linux-netdev&m=122553080530450&w=2, maybe the mail 
client's action is strange. Anyway I have resent them, maybe this time 
it is not corrupted.^_^


