From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: mangle zero checksum in skb_checksum_help()
Date: Mon, 31 Oct 2016 15:29:32 -0400 (EDT)
Message-ID: <20161031.152932.840383254132956388.davem@davemloft.net>
References: <1477764156.7065.282.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56530 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945625AbcJaT3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:29:34 -0400
In-Reply-To: <1477764156.7065.282.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 29 Oct 2016 11:02:36 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Sending zero checksum is ok for TCP, but not for UDP.
> 
> UDPv6 receiver should by default drop a frame with a 0 checksum,
> and UDPv4 would not verify the checksum and might accept a corrupted
> packet.
> 
> Simply replace such checksum by 0xffff, regardless of transport.
> 
> This error was caught on SIT tunnels, but seems generic.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
