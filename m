From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH v2] net: sched: lock imbalance in hhf qdisc
Date: Thu, 01 May 2014 10:12:01 -0700
Message-ID: <1398964321.29914.196.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140501162300.17183.83124.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vtlam@google.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:64792 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaEARMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 13:12:10 -0400
Received: by mail-ig0-f178.google.com with SMTP id hl10so742825igb.5
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 10:12:09 -0700 (PDT)
In-Reply-To: <20140501162300.17183.83124.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 09:23 -0700, John Fastabend wrote:
> hhf_change() takes the sch_tree_lock and releases it but misses the
> error cases. Fix the missed case here.
> 
> To reproduce try a command like this,
> 
> # tc qdisc change dev p3p2 root hhf quantum 40960 non_hh_weight 300000
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/sch_hhf.c |   11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)

Signed-off-by: Eric Dumazet <edumazet@google.com>
