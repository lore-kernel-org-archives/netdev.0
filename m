From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] dccp/tcp: fix ireq->opt races
Date: Fri, 20 Oct 2017 07:04:58 +0100 (WEST)
Message-ID: <20171020.070458.2242397039979446788.davem@davemloft.net>
References: <1508451889.30291.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdJTGN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 02:13:26 -0400
In-Reply-To: <1508451889.30291.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Oct 2017 15:24:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller found another bug in DCCP/TCP stacks [1]
> 
> For the reasons explained in commit ce1050089c96 ("tcp/dccp: fix
> ireq->pktopts race"), we need to make sure we do not access
> ireq->opt unless we own the request sock.
 ...
> Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v3: fixed the whit space mangling
> v2: removed some lines from KASAN report that confuse patchwork.

Much better, applied and queued up for -stable.
