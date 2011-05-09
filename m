From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: Pass flow keys down into datagram packet
 building engine.
Date: Sun, 08 May 2011 21:07:49 -0700 (PDT)
Message-ID: <20110508.210749.193695681.davem@davemloft.net>
References: <20110508.180753.241908549.davem@davemloft.net>
	<Pine.LNX.4.30.1105081811570.26257-100000@mail.perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750743Ab1EIEIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 00:08:22 -0400
In-Reply-To: <Pine.LNX.4.30.1105081811570.26257-100000@mail.perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 8 May 2011 18:14:46 -0700 (PDT)

> On Sun, 8 May 2011, David Miller wrote:
>> +static struct rtable *icmp_route_lookup(struct net *net,
>> +					struct flowi4 *fl4,
>> +					struct sk_buff *skb_in,
>>  					const struct iphdr *iph,
>>  					__be32 saddr, u8 tos,
>>  					int type, int code,
>>  					struct icmp_bxm *param)
>>  {
> []
>> +	memset(&fl4, 0, sizeof(fl4));
> 
> 	memset(fl4, 0, sizeof(*fl4));
> 
>> +	fl4->daddr = (param->replyopts.opt.opt.srr ?
>> +		      param->replyopts.opt.opt.faddr : iph->saddr);
> 

Thanks Joe :-/  I'll fix that.
