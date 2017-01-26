From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] virtio_net: use dev_kfree_skb for small buffer XDP
 receive
Date: Wed, 25 Jan 2017 22:49:02 -0500 (EST)
Message-ID: <20170125.224902.905532481544675405.davem@davemloft.net>
References: <20170126022248.10463.60250.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54426 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdAZDtE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 22:49:04 -0500
In-Reply-To: <20170126022248.10463.60250.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 25 Jan 2017 18:22:48 -0800

> In the small buffer case during driver unload we currently use
> put_page instead of dev_kfree_skb. Resolve this by adding a check
> for virtnet mode when checking XDP queue type. Also name the
> function so that the code reads correctly to match the additional
> check.
> 
> Fixes: bb91accf2733 ("virtio-net: XDP support for small buffers")
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Jason Wang <jasowang@redhat.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
