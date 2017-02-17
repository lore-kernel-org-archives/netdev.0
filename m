From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] pkt_sched: Remove useless qdisc_stab_lock
Date: Fri, 17 Feb 2017 09:42:57 -0800
Message-ID: <1487353377.1311.85.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487313259-103328-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34684 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934253AbdBQSQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:16:17 -0500
Received: by mail-pf0-f193.google.com with SMTP id o64so4566125pfb.1
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 10:15:40 -0800 (PST)
In-Reply-To: <1487313259-103328-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-17 at 14:34 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> The qdisc_stab_lock is used in qdisc_get_stab and qdisc_put_stab.
> These two functions are invoked in qdisc_create, qdisc_change, and
> qdisc_destroy which run fully under RTNL.
> 
> So it already makes sure only one could access the qdisc_stab_list at
> the same time. Then it is unnecessary to use qdisc_stab_lock now.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
