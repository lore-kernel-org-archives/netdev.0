From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Wed, 03 Dec 2014 03:52:26 -0800
Message-ID: <1417607546.5303.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141103.122538.387451917276174830.davem@davemloft.net>
	 <547EBC66.4040301@huawei.com>
	 <1417592482.5303.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <547ED728.2010703@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	willemb@google.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:49356 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbaLCLw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 06:52:29 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so13516841ieb.31
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 03:52:28 -0800 (PST)
In-Reply-To: <547ED728.2010703@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-03 at 17:26 +0800, Yang Yingliang wrote:

> Before this patch, when a large network flow arrives, some other processes
> response slowly or even don't response because the cpu is dealing with softirq.
> 
> After this patch, under pressure, much more softirq is doing in ksoftirqd. The other
> processes be scheduled.
> 
> My system has dual core.

Which NIC driver are you using ?

Thanks
