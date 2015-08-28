From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:32:59 -0700
Message-ID: <55DFF28B.4050302@cumulusnetworks.com>
References: <20150827.220538.2154843333132928646.davem@davemloft.net>
 <55DFEC92.8050700@cumulusnetworks.com> <55DFEDA1.2070903@cumulusnetworks.com>
 <20150827.221753.1685094662698420131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34069 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbbH1FdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:33:03 -0400
Received: by pabzx8 with SMTP id zx8so50588039pab.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 22:33:02 -0700 (PDT)
In-Reply-To: <20150827.221753.1685094662698420131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/27/15 10:17 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Thu, 27 Aug 2015 22:12:01 -0700
>
>> perhaps an example helps:
>>
>> swapper 0 [000] 406.447548: fib:fib_table_lookup: table 255 oif 0 iif
>> 0 src 0.0.0.0 dst 2.1.1.2 tos 0 scope 0 flags 0
>>
>> If src and dst are u32's then they print as either 0x%x or %d which is
>> not intuitive. I added support to perf for the following printk
>> formats with 3d199b5be53:
>   ...
>
> The following had better work:
>
> 	__u32 addr;
> 	printk("%pI4\n", &addr);
>
> We do it everywhere in the networking code.
>
> I don't know why you think it is required to use an array.
>

TP_printk is not printk. See my other response.
