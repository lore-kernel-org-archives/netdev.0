From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 05/15] net: sched: cls_flow use RCU
Date: Tue, 09 Sep 2014 09:20:27 -0700
Message-ID: <1410279627.7106.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	  <20140909055601.2071.43459.stgit@nitbit.x32>
	 <1410266481.11872.158.camel@edumazet-glaptop2.roam.corp.google.com>
	 <540F2640.2080904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:55495 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbaIIQU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 12:20:28 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so1533883pdj.8
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 09:20:28 -0700 (PDT)
In-Reply-To: <540F2640.2080904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-09 at 09:09 -0700, John Fastabend wrote:
> On 09/09/2014 05:41 AM, Eric Dumazet wrote:

> >>   struct flow_filter {
> >>   	struct list_head	list;
> >> +	struct rcu_head		rcu;
> >
> > Please move these 2 new fields at the end of structure, they are only
> > used at dismantle phase.
> >
> > Patch looks fine otherwise, thanks !
> >
> >
> 
> 2 new fields? The first rcu struct is already at end of
> structure. I assume you just mean the rcu struct in flow_filter.

Yes, I was referring to these fields.
