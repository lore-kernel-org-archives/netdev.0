From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v2 3/6] rtnetlink: add helper to dump qdisc name
Date: Sat, 23 Sep 2017 20:38:47 +0200
Message-ID: <20170923183847.GC4324@breakpoint.cc>
References: <20170922061008.14723-1-fw@strlen.de>
 <20170922061008.14723-4-fw@strlen.de>
 <1506187888.29839.181.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46770 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750916AbdIWSmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 14:42:11 -0400
Content-Disposition: inline
In-Reply-To: <1506187888.29839.181.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-09-22 at 08:10 +0200, Florian Westphal wrote:
> > We can use rcu here to make this safe even if we would not hold rtnl:
> > qdisc_destroy uses call_rcu to free the Qdisc struct.
> 
> 
> Where do you see call_rcu() called from qdisc_destroy() ?
> 
> You missed this commit I guess
> 
> 752fbcc33405d6f8249465e4b2c4e420091bb825
> ("net_sched: no need to free qdisc in RCU callback")

Indeed, I did, patch dropped, thanks for the heads-up.
