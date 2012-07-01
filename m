From: John Eaglesham <linux@8192.net>
Subject: Re: [PATCH v5] bonding support for IPv6 transmit hashing
Date: Sun, 01 Jul 2012 12:01:57 -0700
Message-ID: <4FF09EA5.5030605@8192.net>
References: <cover.1341125875.git.linux@8192.net> <c390ff662ede0f304398a88ca1a96e3773065c60.1341129744.git.linux@8192.net> <20120701.033354.539821533277159165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp145.dfw.emailsrvr.com ([67.192.241.145]:37947 "EHLO
	smtp145.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab2GATB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 15:01:58 -0400
In-Reply-To: <20120701.033354.539821533277159165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2012 3:33 AM, David Miller wrote:
> From: John Eaglesham <linux@8192.net>
> Date: Sun,  1 Jul 2012 01:07:43 -0700
>
>> +		v6hash =
>> +			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
>> +			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
>> +			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
>
> You completely ignored my feedback:
>
> 	This is rediculous, just put &ipv6h->saddr into a local
> 	pointer named 's' and then you won't have use such gymnastics
> 	to indent the code.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

My apologies, I completely misunderstood your feedback. I will make the 
correction and re-submit.

Thanks.

John
