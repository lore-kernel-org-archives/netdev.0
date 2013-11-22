From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: tbf: fix an oops when a GSO packet cannot
 be enqueued
Date: Fri, 22 Nov 2013 06:50:01 -0800
Message-ID: <1385131801.10637.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385112446-15564-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ben@decadent.org.uk,
	jpirko@redhat.com, jhs@mojatatu.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:43974 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034Ab3KVOuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 09:50:03 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so1332062pdj.22
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 06:50:02 -0800 (PST)
In-Reply-To: <1385112446-15564-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-22 at 17:27 +0800, Yang Yingliang wrote:
> It seems commit e43ac79a4b("sch_tbf: segment too big GSO packets")
> introduce this oops.
> 
> When GSO mode is on, use the following command:
> tc qdisc add dev eth0 root handle 1: tbf latency 50ms burst 1KB rate 50mbit mtu 1KB
> iperf -c host -t 30

I think your patch is not needed, the stack trace point to a different
spot.

The issue should be fixed by :

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=9d8506cc2d7ea1f911c72c100193a3677f6668c3

Could you check again ?

Thanks
