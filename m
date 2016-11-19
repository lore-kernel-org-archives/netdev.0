From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/5] virtio_net: Do not clear memory for
 struct virtio_net_hdr twice.
Date: Sat, 19 Nov 2016 10:37:28 -0500 (EST)
Message-ID: <20161119.103728.2175790127252213152.davem@davemloft.net>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
        <1479512442-61601-3-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbcKSPha (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 10:37:30 -0500
In-Reply-To: <1479512442-61601-3-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Fri, 18 Nov 2016 15:40:40 -0800

> virtio_net_hdr_from_skb() clears the memory for the header, so there
> is no point for the callers to do the same.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied.
