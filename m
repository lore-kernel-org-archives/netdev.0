From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [Resent] [PATCH 1/2] udp: Fix the SNMP counter of
 UDP_MIB_INDATAGRAMS
Date: Mon, 3 Nov 2008 10:01:42 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0811030959340.19760@netcore.fi>
References: <490C1CA7.3070201@cn.fujitsu.com> <20081101.213529.60503932.davem@davemloft.net> <490E5DB5.4020407@cn.fujitsu.com> <20081102.234625.135160979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:41902 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086AbYKCICC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:02:02 -0500
In-Reply-To: <20081102.234625.135160979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2 Nov 2008, David Miller wrote:
> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> Date: Mon, 03 Nov 2008 10:11:01 +0800
>
>> @@ -158,6 +159,8 @@ try_again:
>>  	else if (copied < ulen)
>>  		msg->msg_flags |= MSG_TRUNC;
>>  +	is_udp4 = (skb->protocol == htons(ETH_P_IP));
>> +

Does this work with non-ethernet link-layers ?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
