From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 5/5] af_packet: Use
 virtio_net_hdr_from_skb() directly.
Date: Sat, 19 Nov 2016 10:37:41 -0500 (EST)
Message-ID: <20161119.103741.2184474918272369205.davem@davemloft.net>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
        <1479512442-61601-5-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34304 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbcKSPhq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 10:37:46 -0500
In-Reply-To: <1479512442-61601-5-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Fri, 18 Nov 2016 15:40:42 -0800

> Remove static function __packet_rcv_vnet(), which only called
> virtio_net_hdr_from_skb() and BUG()ged out if an error code was
> returned.  Instead, call virtio_net_hdr_from_skb() from the former
> call sites of __packet_rcv_vnet() and actually use the error handling
> code that is already there.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied.
