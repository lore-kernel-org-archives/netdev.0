From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]ipv6:use ipv6_addr_type instead of __ipv6_addr_type
Date: Fri, 08 May 2009 16:18:11 +0800
Message-ID: <4A03EAC3.1010601@cn.fujitsu.com>
References: <20090507.145931.179746218.davem@davemloft.net>	<4A038853.4020205@cn.fujitsu.com>	<20090508.004420.22402966.davem@davemloft.net> <20090508.004835.216058418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61984 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbZEHIRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 04:17:05 -0400
In-Reply-To: <20090508.004835.216058418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 08 May 2009 00:44:20 -0700 (PDT)
> 
>> From: Yang Hongyang <yanghy@cn.fujitsu.com>
>> Date: Fri, 08 May 2009 09:18:11 +0800
>>
>>> David Miller wrote:
>>>> From: Yang Hongyang <yanghy@cn.fujitsu.com>
>>>> Date: Thu, 07 May 2009 15:47:38 +0800
>>>>
>>>>> Although the function of these two functions are the same,we should use the
>>>>> encapsulation function of __ipv6_addr_type
>>>>>
>>>>> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
>>>> Are you sure?  ipv6_addr_type() masks out the upper 16-bits
>>>> of __ipv6_addr_type()'s return value, which is the scope.
>>>>
>>>> I'm not convinced that is what we want to do here.
>>> My advice here is that the function which has __ maybe shouldn't be directly used.
> 
> I also want to address this statement on it's own, it's simply
> not true.
> 
> "__" means "think carefully before using this function", or "this
> function requires a special environment for proper usage"
> 
> It DOES NOT mean "do not use directly."  It's never meant this.

I was wrong,thank you for your patience to explain this.

> 
> So ever basis for your patch is fundamentally flawed.
> 
> 


-- 
Regards
Yang Hongyang
