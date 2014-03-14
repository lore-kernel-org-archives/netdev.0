From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Fri, 14 Mar 2014 09:43:15 +0800
Message-ID: <53225EB3.3030605@huawei.com>
References: <5321165A.1000208@huawei.com> <20140313.155230.2146893995359373637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ben@decadent.org.uk>, <john.r.fastabend@intel.com>,
	<kaber@trash.net>, <netdev@vger.kernel.org>, <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:17982 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaCNBoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 21:44:00 -0400
In-Reply-To: <20140313.155230.2146893995359373637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/14 3:52, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Thu, 13 Mar 2014 10:22:18 +0800
> 
>> v1->v2: Convert the vlan_netdev_addr_lock_key to an array of eight elements, which
>> 	could support to add 8 vlan id on a same vlan dev, I think it is enough for current
>> 	scene, because a netdev's name is limited to IFNAMSIZ which could not hold 8 vlan id,
>> 	and the vlan dev would not meet the same class key with its real dev.
>>
>> 	The new function vlan_dev_get_lockdep_subkey() will return the subkey and make the vlan
>> 	dev could get a suitable class key.
> 
> I still am not happy with this solution, unfortunately.  Although I do
> appreciate your efforts.
> 
> I'm going to do some more research into this issue and try to give you
> some more constructive, meaningful, feedback.
> 
> Thanks.
> 
> 
Thanks for any constructive feedback.

Regards
Ding
