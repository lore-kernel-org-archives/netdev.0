From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:07:30 -0700
Message-ID: <55DFEC92.8050700@cumulusnetworks.com>
References: <1440737972-10468-1-git-send-email-dsa@cumulusnetworks.com>
 <20150827.220538.2154843333132928646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33331 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbbH1FHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:07:32 -0400
Received: by padfo6 with SMTP id fo6so11074342pad.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 22:07:32 -0700 (PDT)
In-Reply-To: <20150827.220538.2154843333132928646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/27/15 10:05 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Thu, 27 Aug 2015 21:59:32 -0700
>
>> +		__array(	__u8,	src,	4	)
>> +		__array(	__u8,	dst,	4	)
>   ...
>> +		__array(	__u8,	src,	4	)
>
> Maybe there is something I don't understand about tracing, but why not
> use __u32?  If endianness types are the issue, just force cast it as
> needed.
>
> Using a memcpy() on a 4-byte array is kinda excessive.
>

Silly trick need to use %pI4. ie., printing the addresses as strings vs. 
hex.
