From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:16:43 -0700 (PDT)
Message-ID: <20150827.221643.2144480812551172735.davem@davemloft.net>
References: <1440737972-10468-1-git-send-email-dsa@cumulusnetworks.com>
	<20150827.220538.2154843333132928646.davem@davemloft.net>
	<55DFEC92.8050700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbH1FQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:16:44 -0400
In-Reply-To: <55DFEC92.8050700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 27 Aug 2015 22:07:30 -0700

> On 8/27/15 10:05 PM, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Thu, 27 Aug 2015 21:59:32 -0700
>>
>>> +		__array(	__u8,	src,	4	)
>>> +		__array(	__u8,	dst,	4	)
>>   ...
>>> +		__array(	__u8,	src,	4	)
>>
>> Maybe there is something I don't understand about tracing, but why not
>> use __u32?  If endianness types are the issue, just force cast it as
>> needed.
>>
>> Using a memcpy() on a 4-byte array is kinda excessive.
>>
> 
> Silly trick need to use %pI4. ie., printing the addresses as strings
> vs. hex.

%pI4 doesn't care what kind of pointer you give it, &__entry->src will
work just fine if you used __u32.
