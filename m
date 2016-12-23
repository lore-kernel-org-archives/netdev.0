From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: fix IP(V6)_RECVORIGDSTADDR for udp sockets
Date: Fri, 23 Dec 2016 12:19:38 -0500 (EST)
Message-ID: <20161223.121938.1965120330531794672.davem@davemloft.net>
References: <1482448756-83129-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, njagabar@cloudmark.com,
        samanthakumar@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756066AbcLWRTk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 12:19:40 -0500
In-Reply-To: <1482448756-83129-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu, 22 Dec 2016 18:19:16 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> Socket cmsg IP(V6)_RECVORIGDSTADDR checks that port range lies within
> the packet. For sockets that have transport headers pulled, transport
> offset can be negative. Use signed comparison to avoid overflow.
> 
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> Reported-by: Nisar Jagabar <njagabar@cloudmark.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable.
