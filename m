From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/5] virtio_net: Simplify call sites for
 virtio_net_hdr_{from,to}_skb().
Date: Sat, 19 Nov 2016 10:37:14 -0500 (EST)
Message-ID: <20161119.103714.293011246005811705.davem@davemloft.net>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752985AbcKSPhQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 10:37:16 -0500
In-Reply-To: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Fri, 18 Nov 2016 15:40:38 -0800

> No point storing the return value of virtio_net_hdr_to_skb() or
> virtio_net_hdr_from_skb() to a variable when the value is used only
> once as a boolean in an immediately following if statement.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied.
