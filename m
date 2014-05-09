From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] ipv4: fix kfree static array pointer in ipv4_sysctl_exit_net
Date: Fri, 9 May 2014 12:16:33 +0800
Message-ID: <536C56A1.5080100@huawei.com>
References: <536B34FD.8030601@huawei.com>	<1399552485.7973.2.camel@edumazet-glaptop2.roam.corp.google.com>	<536B7D34.4050104@huawei.com> <CAL4Wiirje=CB6d4_9gnB3P_q1oOQPJVrrdq3zZ+vnPn7C2PLhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:7827 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbaEIER2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 00:17:28 -0400
In-Reply-To: <CAL4Wiirje=CB6d4_9gnB3P_q1oOQPJVrrdq3zZ+vnPn7C2PLhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/9 2:20, Eric Dumazet wrote:
>> No.
>> I just trigger the similar case on sctp when I do 'rmmod -f sctp'.
>> Here I add the init_net case for sctp register sysctl.
>>
>> Is it better to add BUG_ON(net == &init_net) maybe?
>>
> 
> The point is : SCTP _can_ be a module, but IPV4 is not.
> 
> You cannot rmmod ipv4
> 
> Its not because there is a bug in SCTP that you can apply the same
> recipe on another layer.
> 

Well, You are right. So ignore it.

Regards
Wang

> 
