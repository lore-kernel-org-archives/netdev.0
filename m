From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] virtio_net: fix virtnet_open and virtnet_probe
 competing for try_fill_recv
Date: Sun, 29 May 2016 22:31:57 -0700 (PDT)
Message-ID: <20160529.223157.1581425496036382102.davem@davemloft.net>
References: <5746976F.60306@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, liuyongan@huawei.com
To: wangyunjian@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbcE3Fb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:31:59 -0400
In-Reply-To: <5746976F.60306@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: wangyunjian <wangyunjian@huawei.com>
Date: Thu, 26 May 2016 14:27:59 +0800

> In function virtnet_open() and virtnet_probe(), func try_fill_recv()
> will be executed at the same time. VQ in virtqueue_add() is not protected
> well and BUG_ON will be triggered when virito_net.ko being removed.
> 
> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>

Patch is whitespace damanged by your email client.

Fix this, email a test patch to yourself, and do not try to resubmit
this patch to the mailing list until you can successfully apply one of
those test patches.

Thanks.
