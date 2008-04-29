From: Kostya B <bkostya@hotmail.com>
Subject: RE: netif_needs_gso behavior
Date: Tue, 29 Apr 2008 06:46:51 +0000
Message-ID: <BAY121-W26622FC77BB8996E3C2D34B6D90@phx.gbl>
References: <BAY121-W4698632384BFB6587EAB45B6EB0@phx.gbl>
	<20080416.013810.214799502.davem@davemloft.net>
  	<BAY121-W6E46148E896AA4607937CB6EA0@phx.gbl>
  <20080416.180946.242234659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s6.bay0.hotmail.com ([65.54.246.78]:40001 "EHLO
	bay0-omc1-s6.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750848AbYD2Gqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 02:46:52 -0400
In-Reply-To: <20080416.180946.242234659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please follow the further explanations and possible solution in the patch I submitted recently

[PATCH][IPv4] UFO: prevent generation of chained skb
________________________________
> From: bkostya@hotmail.com
> To: davem@davemloft.net
> CC: netdev@vger.kernel.org
> Subject: RE: netif_needs_gso behavior
> Date: Thu, 17 Apr 2008 11:11:50 +0000
> 
> 
> 
>> Date: Wed, 16 Apr 2008 18:09:46 -0700
>> To: bkostya@hotmail.com
>> CC: netdev@vger.kernel.org
>> Subject: Re: netif_needs_gso behavior
>> From: davem@davemloft.net
>>
>> From: Kostya B 
>> Date: Wed, 16 Apr 2008 14:02:56 +0000
>>
>>> Not always, see udp4_hwcsum_outgoing() In the case when socket queue
>>> contains several packets, the csum is reset.
>>
>> USO won't cause this case to occur, I think.
> 
> I see that happens, when rpc over udp is fast enough to put a number of skb into the queue and I have oops in skb_gso_segment() due to having frag_list.
> 
> ________________________________
> Connect to the next generation of MSN Messenger  Get it now! 

_________________________________________________________________
News, entertainment and everything you care about at Live.com. Get it now!
http://www.live.com/getstarted.aspx
