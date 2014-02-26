From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sch_tbf: Fix potential memory leak in tbf_change().
Date: Wed, 26 Feb 2014 07:29:44 -0800
Message-ID: <1393428584.2316.148.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140226214342.585acf597a84276fc152fc7e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yangyingliang@huawei.com
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:37648 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbaBZP3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 10:29:47 -0500
Received: by mail-pa0-f49.google.com with SMTP id hz1so1106219pad.36
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 07:29:46 -0800 (PST)
In-Reply-To: <20140226214342.585acf597a84276fc152fc7e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 21:43 +0900, Hiroaki SHIMODA wrote:
> The allocated child qdisc is not freed in error conditions.
> Defer the allocation after user configuration turns out to be
> valid and acceptable.
> 
> Fixes: cc106e4 ("net: sched: tbf: fix the calculation of max_size")

Please prefer/use 12 digits : cc106e441a63b

You can put in your .git/config file :

[core]
	...
	abbrev = 12
	...

> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Cc: Yang Yingliang <yangyingliang@huawei.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
