From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue immediately
 after it's detached from sk
Date: Mon, 11 Apr 2016 19:57:26 +0800
Message-ID: <570B9126.9080806@huawei.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FB6AA7.1080004@huawei.com>
 <1459345637.6473.205.camel@edumazet-glaptop3.roam.corp.google.com>
 <5705F759.9020003@huawei.com>
 <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
 <5707939B.2030907@huawei.com>
 <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([58.251.152.52]:56338 "EHLO
	szxga04-in.huawei.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754151AbcDKL6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 07:58:07 -0400
In-Reply-To: <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/4/8 22:44, Eric Dumazet wrote:
> On Fri, 2016-04-08 at 19:18 +0800, Yang Yingliang wrote:
>
>> I expand  tcp_adv_win_scale and tcp_rmem. It has no effect.
>
> Try :
>
> echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale
>
> And restart your flows.
>
cat /proc/sys/net/ipv4/tcp_rmem
10240 2097152 10485760

echo 102400 20971520 104857600 > /proc/sys/net/ipv4/tcp_rmem
echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale

It seems has not effect.
