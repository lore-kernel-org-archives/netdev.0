From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fixes for header length truncation
Date: Wed, 08 Feb 2017 13:56:00 -0500 (EST)
Message-ID: <20170208.135600.972593747129196769.davem@davemloft.net>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        sowmini.varadhan@oracle.com, dvyukov@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdBHS5f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:57:35 -0500
In-Reply-To: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue,  7 Feb 2017 15:57:19 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> Packets should not enter the stack with truncated link layer headers
> and link layer headers should always be stored in the skb linear
> segment.
> 
> Patch 1 ensures the first for PF_PACKET sockets
> Patch 2 ensures the second for PF_PACKET GSO sockets without tx_ring

Nice work, I'll apply this series and queue it up for -stable.

Thanks!
