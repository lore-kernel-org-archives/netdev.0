From: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Subject: [Questions]
Date: Wed, 20 Aug 2014 17:37:01 +0800
Message-ID: <53F46C3D.1030106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <liuyongan@huawei.com>, <qinchuanyu@huawei.com>,
	<zhangjie14@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <kvm@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:34110 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaHTJhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 05:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi MST,

I see "reduce networking latency"
from Networking Todo, the idea is to "allow handling short packets from softirq or VCPU context".
If from softirq context, how could softirq copy skb to guest memory? If the method is to use mmstruct of Qemu,
would it be expensive?
If from VCPU context, maybe the internal operation of the virtual machine will have a significant delay.

Thanks!
-- 
Best Wishes!
Zhang Jie
