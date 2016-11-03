From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: netlink_diag_dump() runs without locks
Date: Thu, 03 Nov 2016 16:20:19 -0400 (EDT)
Message-ID: <20161103.162019.2109271991889343912.davem@davemloft.net>
References: <1478141906.7065.421.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAAeHK+xUFKMfW4WoYgyjJeYJZm_gAg3Nr3S0+8M-5H+6a=RVKw@mail.gmail.com>
        <1478143280.7065.427.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, herbert@gondor.apana.org.au,
        akpm@linux-foundation.org, decot@googlers.com,
        dmitrijs.ivanovs@ubnt.com, edumazet@google.com, fw@strlen.de,
        grose@lightfleet.com, johannes.berg@intel.com,
        matti.vaittinen@nokia.com, pshelar@ovn.org,
        stephen@networkplumber.org, tom@herbertland.com,
        tycho.andersen@canonical.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, syzkaller@googlegroups.com, kcc@google.com,
        glider@google.com, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758189AbcKCUUX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:20:23 -0400
In-Reply-To: <1478143280.7065.427.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 20:21:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> A recent commit removed locking from netlink_diag_dump() but forgot
> one error case.
 ...
> Fixes: ad202074320c ("netlink: Use rhashtable walk interface in diag dump")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied.
