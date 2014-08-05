From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Query: Is it possible  to lose interrupts between vhost and
 virtio_net during migration?
Date: Tue, 5 Aug 2014 11:49:57 +0200
Message-ID: <20140805094957.GB24619@redhat.com>
References: <53DA2CCC.1040606@huawei.com>
 <20140731143100.GA3834@redhat.com>
 <20140731143725.GA3875@redhat.com>
 <53DB705F.2000405@redhat.com>
 <53DB76A9.8010305@redhat.com>
 <53E079C8.7050700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	qinchuanyu@huawei.com, liuyongan@huawei.com, davem@davemloft.net
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933035AbaHEJuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 05:50:06 -0400
Content-Disposition: inline
In-Reply-To: <53E079C8.7050700@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2014 at 02:29:28PM +0800, Zhangjie (HZ) wrote:
> Jason is right, the new order is not the cause of network unreachable.
> Changing order seems not work. After about 40 times, the problem occurs again.
> Maybe there is other hidden reasons for that.

To make sure, you tested the patch that I posted to list:
"vhost_net: stop guest notifiers after backend"?

Please confirm.

-- 
MST
