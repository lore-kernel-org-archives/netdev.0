From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/2] vlan: don't allow vlan device to move between
 network namespaces
Date: Mon, 3 Mar 2014 08:57:51 +0800
Message-ID: <5313D38F.6080009@huawei.com>
References: <1393573839-32316-1-git-send-email-dingtianhong@huawei.com>	 <1393573839-32316-2-git-send-email-dingtianhong@huawei.com>	 <531044E1.6070005@lab.ntt.co.jp> <53104E4D.8060706@huawei.com> <1393592834.1744.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>, <kaber@trash.net>,
	<julia.lawall@lip6.fr>, <joe@perches.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41732 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbaCCA6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 19:58:32 -0500
In-Reply-To: <1393592834.1744.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/28 21:07, Toshiaki Makita wrote:
> On Fri, 2014-02-28 at 16:52 +0800, Ding Tianhong wrote:
>> On 2014/2/28 16:12, Toshiaki Makita wrote:
>>> (2014/02/28 16:50), Ding Tianhong wrote:
>>>> Now the vlan device could move to another network namespace, but
>>>> the read dev is sill in the old network namespace, it is unsafe
>>>> and the vlan device could not work well, so don't allow to do it.
>>>
>>> Why is this a problem?
>>> This looks like a useful feature to me.
>>>
>>> Thanks,
>>> Toshiaki Makita
>>>
>> I think the vlan dev is a virtual device, if it does not with real dev together,
>> I am not sure whether it is correct. Maybe I miss something, pls remind me.
> 
> It can be used to aggregate/distribute traffic from/to each namespace.
> We can use vlan ids as identifiers for namespaces.
> If there is a problem with this usage, I don't want to disable this
> feature but want to fix the exact problem.
> 
> Thanks,
> Toshiaki Makita
> 

OK, I got it and agree with you.

Regards
Ding
> 
> 
