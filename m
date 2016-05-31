From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] virtio_net: fix virtnet_open and virtnet_probe
 competing for try_fill_recv
Date: Tue, 31 May 2016 14:22:59 -0700 (PDT)
Message-ID: <20160531.142259.185396177679283647.davem@davemloft.net>
References: <1464666763-12136-1-git-send-email-wangyunjian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, liuyongan@huawei.com
To: wangyunjian@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbcEaVXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 17:23:00 -0400
In-Reply-To: <1464666763-12136-1-git-send-email-wangyunjian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yunjian Wang <wangyunjian@huawei.com>
Date: Tue, 31 May 2016 11:52:43 +0800

> In function virtnet_open() and virtnet_probe(), func try_fill_recv() may
> be executed at the same time. VQ in virtqueue_add() has not been protected
> well and BUG_ON will be triggered when virito_net.ko being removed.
> 
> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
> Acked-by: Jason Wang <jasowang@redhat.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
