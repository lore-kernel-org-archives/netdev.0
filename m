From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan
 tag by hand
Date: Wed, 09 Jul 2008 00:18:33 +0200
Message-ID: <4873E7B9.2020304@trash.net>
References: <4873B6E1.9010702@trash.net>	<20080708193351.GE14330@xi.wantstofly.org>	<4873CAFB.8040606@trash.net> <20080708.150257.41516850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, nico@cam.org, dale@farnsworth.org,
	akarkare@marvell.com, jdb@comx.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41171 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442AbYGHWSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:18:39 -0400
In-Reply-To: <20080708.150257.41516850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 08 Jul 2008 22:15:55 +0200
>
>   
>> Great, thanks. The patch applies cleanly with or without the VLAN
>> packet socket patches I sent today, so Dave can either just apply
>> it together with your mv643xx_eth patch or I'll include it when
>> sending the next VLAN update.
>>     
>
> Patrick, want me to stuff this one into net-2.6?
>
> BTW, there is a typo in the commit message, you say
> "skb_cow_header()" which doesn't exist, you mean "skb_cow_head()".
> But you got it right in the code :)
>   

I would feel better putting it in net-next-2.6.git. The code
currently doesn't handle shared skbs and it does look unnecessary.
But if we actually get one it will BUG in pskb_expand_head().


