From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/6] rtnetlink: add helper to dump qdisc name
Date: Sat, 23 Sep 2017 10:31:28 -0700
Message-ID: <1506187888.29839.181.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170922061008.14723-1-fw@strlen.de>
         <20170922061008.14723-4-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34010 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdIWRba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 13:31:30 -0400
Received: by mail-pf0-f195.google.com with SMTP id g65so1815436pfe.1
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 10:31:30 -0700 (PDT)
In-Reply-To: <20170922061008.14723-4-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 08:10 +0200, Florian Westphal wrote:
> We can use rcu here to make this safe even if we would not hold rtnl:
> qdisc_destroy uses call_rcu to free the Qdisc struct.


Where do you see call_rcu() called from qdisc_destroy() ?

You missed this commit I guess

752fbcc33405d6f8249465e4b2c4e420091bb825
("net_sched: no need to free qdisc in RCU callback")
