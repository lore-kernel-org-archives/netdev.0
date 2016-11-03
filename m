From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ip: add RECVFRAGSIZE cmsg
Date: Thu, 03 Nov 2016 15:41:30 -0400 (EDT)
Message-ID: <20161103.154130.1088642095324149430.davem@davemloft.net>
References: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jdorfman@google.com,
        eric.dumazet@gmail.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752308AbcKCTlc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 15:41:32 -0400
In-Reply-To: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed,  2 Nov 2016 11:02:15 -0400

> On IP datagrams and raw sockets, when packets arrive fragmented,
> expose the largest received fragment size through a new cmsg.
> 
> Protocols implemented on top of these sockets may use this, for
> instance, to inform peers to lower MSS on platforms that silently
> allow send calls to exceed PMTU and cause fragmentation.

Looks good, series applied, thanks Willem.
