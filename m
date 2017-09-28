From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: only test po->has_vnet_hdr once in
 packet_snd
Date: Thu, 28 Sep 2017 10:25:10 -0700 (PDT)
Message-ID: <20170928.102510.511287414213184138.davem@davemloft.net>
References: <20170926162017.60750-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751978AbdI1RZL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:25:11 -0400
In-Reply-To: <20170926162017.60750-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aFrom: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 26 Sep 2017 12:20:17 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Packet socket option po->has_vnet_hdr can be updated concurrently with
> other operations if no ring is attached.
> 
> Do not test the option twice in packet_snd, as the value may change in
> between calls. A race on setsockopt disable may cause a packet > mtu
> to be sent without having GSO options set.
> 
> Fixes: bfd5f4a3d605 ("packet: Add GSO/csum offload support.")
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
