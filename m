From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue immediately
 after it's detached from sk
Date: Thu, 7 Apr 2016 14:01:07 +0800
Message-ID: <5705F7A3.6060300@huawei.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
 <56FBCCF6.80203@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([58.251.152.52]:25075 "EHLO
	szxga04-in.huawei.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750784AbcDGGB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 02:01:58 -0400
In-Reply-To: <56FBCCF6.80203@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/3/30 20:56, Sergei Shtylyov wrote:
> Hello.
>
> On 3/30/2016 8:16 AM, Yang Yingliang wrote:
>
>> When task A hold the sk owned in tcp_sendmsg, if lots of packets
>> arrive and the packets will be added to backlog queue. The packets
>> will be handled in release_sock called from tcp_sendmsg. When the
>> sk_backlog is removed from sk, the length will not decrease until
>> all the packets in backlog queue are handled. This may leads to the
>> new packets be dropped because the lenth is too big. So set the
>> lenth to 0 immediately after it's detached from sk.
>
>     Length?
>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> [...]
>
> MBR, Sergei
>
>
Yes. It's a typo.

Thanks
Yang
