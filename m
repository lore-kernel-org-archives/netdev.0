From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH net] sch_tbf: Fix potential memory leak in tbf_change().
Date: Thu, 27 Feb 2014 07:43:04 +0900
Message-ID: <20140227074304.38df5ee3530155052b825b88@gmail.com>
References: <20140226214342.585acf597a84276fc152fc7e@gmail.com>
	<1393428584.2316.148.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yangyingliang@huawei.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:59463 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaBZWnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:43:07 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so1553714pdj.31
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 14:43:07 -0800 (PST)
In-Reply-To: <1393428584.2316.148.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Feb 2014 07:29:44 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-02-26 at 21:43 +0900, Hiroaki SHIMODA wrote:
> > The allocated child qdisc is not freed in error conditions.
> > Defer the allocation after user configuration turns out to be
> > valid and acceptable.
> > 
> > Fixes: cc106e4 ("net: sched: tbf: fix the calculation of max_size")
> 
> Please prefer/use 12 digits : cc106e441a63b
> 
> You can put in your .git/config file :
> 
> [core]
> 	...
> 	abbrev = 12
> 	...

Thank you for your kind suggestion.
I will use 12 digits next time.

> > Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> > Cc: Yang Yingliang <yangyingliang@huawei.com>
> > ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks
> 
> 
