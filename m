From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next] net_sched: add messages to distinguish errors
 when modify qdisc
Date: Wed, 11 Dec 2013 10:37:01 +0800
Message-ID: <52A7CFCD.5010906@huawei.com>
References: <1386665340-16820-1-git-send-email-yangyingliang@huawei.com> <20131210.134702.693746793840315797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:37928 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab3LKChQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 21:37:16 -0500
In-Reply-To: <20131210.134702.693746793840315797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/11 2:47, David Miller wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> Date: Tue, 10 Dec 2013 16:49:00 +0800
> 
>> When tc_modify_qdisc return EINVAL, user cannot distinguish
>> errors easliy. Add some messages to make it easier.
>>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> 
> There is no chance I am ever going to apply a patch like this one,
> sorry.
> 
> If the indication to userspace is not fine grained enough, fix that.
> Don't spam the kernel log with random messages triggerable by the
> user.
> 
> 
Ok, thanks!

Then how about change the errno, is that ok ?
