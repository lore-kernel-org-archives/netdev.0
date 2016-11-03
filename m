From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: dccp: fix out of bound access in
 dccp_v6_err()
Date: Thu, 03 Nov 2016 16:20:32 -0400 (EDT)
Message-ID: <20161103.162032.1632688241226729817.davem@davemloft.net>
References: <1478138440.7065.419.camel@edumazet-glaptop3.roam.corp.google.com>
        <1478143848.7065.429.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758483AbcKCUUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:20:34 -0400
In-Reply-To: <1478143848.7065.429.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 20:30:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> dccp_v6_err() does not use pskb_may_pull() and might access garbage.
> 
> We only need 4 bytes at the beginning of the DCCP header, like TCP,
> so the 8 bytes pulled in icmpv6_notify() are more than enough.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queue up for -stable.

Thanks Eric.
