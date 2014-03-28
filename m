From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Fri, 28 Mar 2014 09:13:27 +0800
Message-ID: <5334CCB7.9040703@huawei.com>
References: <5321165A.1000208@huawei.com>	<20140314.220253.2108022241165181233.davem@davemloft.net>	<53266735.8050607@huawei.com> <20140327.130604.103963458048959251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ben@decadent.org.uk>, <john.r.fastabend@intel.com>,
	<kaber@trash.net>, <netdev@vger.kernel.org>, <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:49963 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757256AbaC1BNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 21:13:54 -0400
In-Reply-To: <20140327.130604.103963458048959251.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/28 1:06, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Mon, 17 Mar 2014 11:08:37 +0800
> 
>> On 2014/3/15 10:02, David Miller wrote:
>>> From: Ding Tianhong <dingtianhong@huawei.com>
>>> Date: Thu, 13 Mar 2014 10:22:18 +0800
>>>
>>>> When I open the LOCKDEP config and run these steps:
>>>
>>> This doesn't work?
>>>
>>
>> It make no sense, I have try it before, the class check only focus on the lock_class_key,
>> not the lockdep_subclass_key.
> 
> I think the issue is that not all of the addrlist locking uses _nested() variants,
> I think if we do that, this will all work.
> 
> I do not want to add a huge array of locking keys to fix this, it's a waste of
> static kernel memory and inelegant.
> 
> 
OK, ready for fix this again with new idea, thanks.

Ding
