From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: internal implementation for pacing
Date: Tue, 16 May 2017 15:46:03 -0400 (EDT)
Message-ID: <20170516.154603.1535037554071319687.davem@davemloft.net>
References: <20170516112436.10189-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        ncardwell@google.com, ycheng@google.com, vanj@google.com,
        hkchu@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752890AbdEPTqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:46:35 -0400
In-Reply-To: <20170516112436.10189-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 16 May 2017 04:24:36 -0700

> BBR congestion control depends on pacing, and pacing is
> currently handled by sch_fq packet scheduler for performance reasons,
> and also because implemening pacing with FQ was convenient to truly
> avoid bursts.
> 
> However there are many cases where this packet scheduler constraint
> is not practical.
> - Many linux hosts are not focusing on handling thousands of TCP
>   flows in the most efficient way.
> - Some routers use fq_codel or other AQM, but still would like
>   to use BBR for the few TCP flows they initiate/terminate.
> 
> This patch implements an automatic fallback to internal pacing.
 ...

Looks great, applied, thanks!
