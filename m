From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] ipv4: convert dst_metrics.refcnt from
 atomic_t to refcount_t
Date: Fri, 18 Aug 2017 15:14:24 -0700 (PDT)
Message-ID: <20170818.151424.887124840705267368.davem@davemloft.net>
References: <1502925599.4936.153.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAM_iQpWbxs6aa-axQrwN5pipaCDX3ws_08LaQON8p4WfrJ7SDg@mail.gmail.com>
        <1503083287.22502.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752111AbdHRWOY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:14:24 -0400
In-Reply-To: <1503083287.22502.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Aug 2017 12:08:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v3: added the include <linux/refcount.h> to be safe (Cong Wang)
> v2: fix a missing change in net/ipv4/fib_semantics.c

Applied, thanks Eric.
