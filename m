From: John Eaglesham <linux@8192.net>
Subject: Re: [PATCH V3 1/2] bonding support for IPv6 transmit hashing
Date: Sat, 30 Jun 2012 12:50:17 -0700
Message-ID: <4FEF5879.5070201@8192.net>
References: <4FEE99E7.9010504@8192.net> <20120630.010514.79398765104671796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp153.dfw.emailsrvr.com ([67.192.241.153]:34940 "EHLO
	smtp153.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab2F3TuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 15:50:14 -0400
In-Reply-To: <20120630.010514.79398765104671796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/30/2012 1:05 AM, David Miller wrote:
>
> If you're going to post multiple patches, give them unique
> subject line texts describing what each change does uniquely.
> Do not use identical subject lines ever, that is very unhelpful
> for the people reading your changes.
>
> From: John <linux@8192.net>
> Date: Fri, 29 Jun 2012 23:17:11 -0700
>
>> + skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
>> +		ipv6h = ipv6_hdr(skb);
>> +		v6hash =
>> + (ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
>> + (ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
>> + (ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
>> +		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
>> + return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
>
> Either you formatted this terribly, or your email client corrupted
> your patches.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Thanks for the feedback. It must have been my mail client formatting 
that incorrectly. I will re-submit with useful subject lines in a method 
that preserves the intended indentation.

John
