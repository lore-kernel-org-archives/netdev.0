From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/5] af_packet: Use virtio_net_hdr_to_skb().
Date: Sat, 19 Nov 2016 10:37:35 -0500 (EST)
Message-ID: <20161119.103735.504649009539309859.davem@davemloft.net>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
        <1479512442-61601-4-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbcKSPhg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 10:37:36 -0500
In-Reply-To: <1479512442-61601-4-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Fri, 18 Nov 2016 15:40:41 -0800

> Use the common virtio_net_hdr_to_skb() instead of open coding it.
> Other call sites were changed by commit fd2a0437dc, but this one was
> missed, maybe because it is split in two parts of the source code.
> 
> Interim comparisons of 'vnet_hdr->gso_type' still work as both the
> vnet_hdr and skb notion of gso_type is zero when there is no gso.
> 
> Fixes: fd2a0437dc ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied.
