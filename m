From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V5 0/9] vhost_net rx batch dequeuing
Date: Thu, 18 May 2017 10:08:11 -0400 (EDT)
Message-ID: <20170518.100811.2191248929136476886.davem@davemloft.net>
References: <1494994485-12994-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756066AbdEROIQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:08:16 -0400
In-Reply-To: <1494994485-12994-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 17 May 2017 12:14:36 +0800

> This series tries to implement rx batching for vhost-net. This is done
> by batching the dequeuing from skb_array which was exported by
> underlayer socket and pass the sbk back through msg_control to finish
> userspace copying. This is also the requirement for more batching
> implemention on rx path.
> 
> Tests shows at most 7.56% improvment bon rx pps on top of batch
> zeroing and no obvious changes for TCP_STREAM/TCP_RR result.

Series applied, thanks Jason.
