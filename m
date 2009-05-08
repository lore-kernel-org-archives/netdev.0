From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]ipv6:use ipv6_addr_type instead of __ipv6_addr_type
Date: Fri, 08 May 2009 09:18:11 +0800
Message-ID: <4A038853.4020205@cn.fujitsu.com>
References: <4A02921A.1090200@cn.fujitsu.com> <20090507.145931.179746218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63120 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752676AbZEHBRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 21:17:07 -0400
In-Reply-To: <20090507.145931.179746218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Yang Hongyang <yanghy@cn.fujitsu.com>
> Date: Thu, 07 May 2009 15:47:38 +0800
> 
>> Although the function of these two functions are the same,we should use the
>> encapsulation function of __ipv6_addr_type
>>
>> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
> 
> Are you sure?  ipv6_addr_type() masks out the upper 16-bits
> of __ipv6_addr_type()'s return value, which is the scope.
> 
> I'm not convinced that is what we want to do here.

My advice here is that the function which has __ maybe shouldn't be directly used.

Since the return of  __ipv6_addr_type is needed by 
__ipv6_addr_src_scope,there should comes another patch to covert use of
__ipv6_addr_src_scope to ipv6_addr_src_scope.To make this serie of the
patch shouldn't be a problem because there are not so much use of these, 
two or three places.

That's my advice.:)

-- 
Regards
Yang Hongyang
