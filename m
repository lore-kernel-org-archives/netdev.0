From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]ipv6:use ipv6_addr_type instead of __ipv6_addr_type
Date: Fri, 08 May 2009 00:44:20 -0700 (PDT)
Message-ID: <20090508.004420.22402966.davem@davemloft.net>
References: <4A02921A.1090200@cn.fujitsu.com>
	<20090507.145931.179746218.davem@davemloft.net>
	<4A038853.4020205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753732AbZEHHoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 03:44:25 -0400
In-Reply-To: <4A038853.4020205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Fri, 08 May 2009 09:18:11 +0800

> David Miller wrote:
>> From: Yang Hongyang <yanghy@cn.fujitsu.com>
>> Date: Thu, 07 May 2009 15:47:38 +0800
>> 
>>> Although the function of these two functions are the same,we should use the
>>> encapsulation function of __ipv6_addr_type
>>>
>>> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
>> 
>> Are you sure?  ipv6_addr_type() masks out the upper 16-bits
>> of __ipv6_addr_type()'s return value, which is the scope.
>> 
>> I'm not convinced that is what we want to do here.
> 
> My advice here is that the function which has __ maybe shouldn't be directly used.

You're using vague terms like "advice" and "maybe" and this
only decreases my confidence in your change.

You're also not addressing my questions at all.

Two "_" characters at the beginning of the function's name says
nothing about whether these call sites want the scope bits present in
the return value they receive.

This seems like a completely pointless and mindless change,
and in fact might introduce bugs.

There is no way I'm applying this.  You can't even explain if the
patch is correct or not.  In fact, I doubt you even know.

