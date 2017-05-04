From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp: do not inherit fastopen_req from parent
Date: Thu, 04 May 2017 11:00:57 -0400 (EDT)
Message-ID: <20170504.110057.23190424531991586.davem@davemloft.net>
References: <1493818595.7796.11.camel@edumazet-glaptop3.roam.corp.google.com>
        <1493818771.7796.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiwan@google.com, andreyknvl@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752828AbdEDPA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:00:59 -0400
In-Reply-To: <1493818771.7796.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 May 2017 06:39:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Under fuzzer stress, it is possible that a child gets a non NULL
> fastopen_req pointer from its parent at accept() time, when/if parent
> morphs from listener to active session.
> 
> We need to make sure this can not happen, by clearing the field after
> socket cloning.
 ...
> Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
> Fixes: 7db92362d2fe ("tcp: fix potential double free issue for fastopen_req")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
