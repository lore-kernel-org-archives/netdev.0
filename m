From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 5/5] introduce udp_rmem and udp_wmem
Date: Sat, 03 Nov 2007 00:42:00 +0900
Message-ID: <472B4548.7090603@redhat.com>
References: <47264E2D.4080109@redhat.com>	<47264F5F.6040905@redhat.com> <20071030005248.b0e6e9d2.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753565AbXKBPuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 11:50:37 -0400
In-Reply-To: <20071030005248.b0e6e9d2.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm sorry to not respond quickly.

Bill Fink wrote:
> On Mon, 29 Oct 2007, Hideo AOKI wrote:
> 
>> This patch added /proc/sys/net/udp_rmem and /proc/sys/net/udp_rmem.
>> Each UDP packet is drooped when the number of pages for socket buffer
>> is beyond the limit and the socket already consumes minimum buffer.
> 
> I think you meant /proc/sys/net/ipv4/udp_{r,w}mem above.

You're right. New parameters are added to /proc/sys/net/ipv4.

> Patch not in-lined making replying more difficult.

I apologize for the inconvenient. I'll send patch as in-line next time.

>>> +udp_rmem - INTEGER
>> +	Minimal size of receive buffer used by UDP sockets. Each UDP socket
>> +	is able to use the size for receiving data, even if total pages of UDP
>> +	sockets exceed udp_mem. The unit is byte.
>> +	Default: 4096
>> +
>> +udp_wmem - INTEGER
>> +	Minimal size of send buffer used by UDP sockets. Each UDP socket is
>> +	able to use the size for sending data, even if total pages of UDP
>> +	sockets exceed udp_mem. The unit is byte.
>> +	Default: 4096
>> +
>>  CIPSOv4 Variables:
>>  
>>  cipso_cache_enable - BOOLEAN
> 
> I think either the above should be renamed to udp_{r,w}mem_min, or
> they should be changed to a 3-tuple like tcp_{r,w}mem, and the code
> refactored accordingly (but then what to do about
> /proc/sys/net/core/{r,w}mem_max).
> 
> 						-Bill

I understood. Then, I'll rename them to udp_{r,w}mem_min next take.
Please let me know if there is any suggestions.

Many thanks,
Hideo

-- 
Hitachi Computer Products (America) Inc.

