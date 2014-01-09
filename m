From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 3/3] net: Add GRO support for vxlan traffic
Date: Thu, 9 Jan 2014 08:28:06 +0200
Message-ID: <52CE4176.9070600@mellanox.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>	 <1389213278-2200-4-git-send-email-ogerlitz@mellanox.com> <1389218977.31367.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog124.obsmtp.com ([207.126.144.157]:53461 "EHLO
	eu1sys200aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751135AbaAIG2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 01:28:09 -0500
In-Reply-To: <1389218977.31367.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 00:09, Eric Dumazet wrote:
> On Wed, 2014-01-08 at 22:34 +0200, Or Gerlitz wrote:
>> +
>> +static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
>> +{
>> +	struct ethhdr *eh;
>> +	struct packet_offload *ptype;
>> +	__be16 type;
>> +	/* 22 = 8 bytes for the vlxan header + 14 bytes for the inner eth header */
>> +	int vxlan_len  = 22;
>
>
> I am pretty sure this can use existing macros or sizeof(...)

sure, will fix



>
