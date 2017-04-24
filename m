From: David Miller <davem@davemloft.net>
Subject: Re: Blogpost evaluation this [PATCH v4 net-next RFC] net: Generic
 XDP
Date: Mon, 24 Apr 2017 18:26:43 -0400 (EDT)
Message-ID: <20170424.182643.485613135674690555.davem@davemloft.net>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
        <20170424162405.1183f2e7@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xdp-newbies@vger.kernel.org, netdev@vger.kernel.org,
        andy@greyhouse.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967445AbdDXW0p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 18:26:45 -0400
In-Reply-To: <20170424162405.1183f2e7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 24 Apr 2017 16:24:05 +0200

> I've done a very detailed evaluation of this patch, and I've created a
> blogpost like report here:
> 
>  https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html

Thanks for doing this Jesper.

> I didn't evaluate the adjust_head part, so I hope Andy is still
> planning to validate that part?

I was hoping he would post some results today as well.

Andy, how goes it? :)

Once the basic patch is ready and integrated in we can try to do
xmit_more in generic XDP and see what that does for XDP_TX
performance.
