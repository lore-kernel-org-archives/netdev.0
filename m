From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/3] Fixes for XDP/BPF
Date: Fri, 08 Sep 2017 21:11:17 -0700 (PDT)
Message-ID: <20170908.211117.1564455188514198482.davem@davemloft.net>
References: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdIIELS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 00:11:18 -0400
In-Reply-To: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 08 Sep 2017 14:00:05 -0700

> The following fixes, UAPI updates, and small improvement,
> 
> i. XDP needs to be called inside RCU with preempt disabled.
> 
> ii. Not strictly a bug fix but we have an attach command in the
> sockmap UAPI already to avoid having a single kernel released with
> only the attach and not the detach I'm pushing this into net branch.
> Its early in the RC cycle so I think this is OK (not ideal but better
> than supporting a UAPI with a missing detach forever).
> 
> iii. Final patch replace cpu_relax with cond_resched in devmap.

Series applied, thanks John.
