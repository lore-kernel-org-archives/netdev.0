From: chenweilong <chenweilong@huawei.com>
Subject: Re: [PATCH 3.4-stable] ipv6: reallocate addrconf router for ipv6
 address when lo, device up
Date: Wed, 6 Aug 2014 16:01:30 +0800
Message-ID: <53E1E0DA.9070308@huawei.com>
References: <53A233D9.8070202@huawei.com> <20140724.210839.866750629795894870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:42822 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbaHFIBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 04:01:51 -0400
In-Reply-To: <20140724.210839.866750629795894870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry.
I'll change it.

On 2014/7/25 12:08, David Miller wrote:
> From: chenweilong <chenweilong@huawei.com>
> Date: Thu, 19 Jun 2014 08:50:33 +0800
> 
>> Please queue this for 3.4 stable kernel.
>  ...
>> +					dst_release(sp_ifa->rt);
> 
> dst_release() does not take a "struct rt6_info *", and therefore
> the compile warns when you try to compile this.
> 
> For something like -stable, we should be as conservative as possible,
> I expect at a minimum that you look at the build for warnings added by
> your change.
> 
> 
