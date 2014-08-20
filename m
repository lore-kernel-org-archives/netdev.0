From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Questions]
Date: Wed, 20 Aug 2014 12:05:20 +0200
Message-ID: <20140820100520.GA16698@redhat.com>
References: <53F46C3D.1030106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kvm@vger.kernel.org, liuyongan@huawei.com,
	qinchuanyu@huawei.com
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27707 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864AbaHTKE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2014 06:04:58 -0400
Content-Disposition: inline
In-Reply-To: <53F46C3D.1030106@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 20, 2014 at 05:37:01PM +0800, Zhangjie (HZ) wrote:
> Hi MST,
> 
> I see "reduce networking latency"
> from Networking Todo, the idea is to "allow handling short packets from softirq or VCPU context".
> If from softirq context, how could softirq copy skb to guest memory? If the method is to use mmstruct of Qemu,
> would it be expensive?

I have some very rough patches to explain this part of the idea.
Will dig them out for you.

> If from VCPU context, maybe the internal operation of the virtual machine will have a significant delay.

We'd have to find a good heuristic here.
Maybe for a small number of very short packets the delay won't be significant.

> Thanks!
> -- 
> Best Wishes!
> Zhang Jie
