From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Mon, 10 Mar 2014 10:08:35 +0800
Message-ID: <531D1EA3.2060708@huawei.com>
References: <5318828D.3090308@huawei.com>	<20140306.145126.497070034648321818.davem@davemloft.net>	<5319270D.4030602@huawei.com> <20140307.014932.157368387111603644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ben@decadent.org.uk>, <john.r.fastabend@intel.com>,
	<kaber@trash.net>, <netdev@vger.kernel.org>, <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:35006 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbaCJCKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 22:10:10 -0400
In-Reply-To: <20140307.014932.157368387111603644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/7 14:49, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Fri, 7 Mar 2014 09:55:25 +0800
> 
>> But I think if I vconfig add eth2.20.30 50, the warning would happen
>> again, but till now I could not find any scene that use 3 vlan id on
>> a virtual device, so I think it is not a problem.
> 
> My example was to show that you aren't really fixing the bug, but
> rather are papering over it.
> 
> In that sense, it is a problem.
> 
> I also happen to disagree with your assertion that a 3 layered
> VLAN is invalid, it is valid.  And if we allow the configuration
> it shouldn't throw locking assertions.
> 
> 
OK, thanks for your advise. I would think and solve this problem once-again.

Regards
Ding
