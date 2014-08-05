From: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Subject: Re: Query: Is it possible  to lose interrupts between vhost and virtio_net
 during migration?
Date: Tue, 5 Aug 2014 20:14:28 +0800
Message-ID: <53E0CAA4.8010303@huawei.com>
References: <53DA2CCC.1040606@huawei.com> <20140731143100.GA3834@redhat.com> <20140731143725.GA3875@redhat.com> <53DB705F.2000405@redhat.com> <53DB76A9.8010305@redhat.com> <53E079C8.7050700@huawei.com> <20140805094957.GB24619@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, <netdev@vger.kernel.org>,
	<qinchuanyu@huawei.com>, <liuyongan@huawei.com>,
	<davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>, <kvm@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25782 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbaHEMPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 08:15:22 -0400
In-Reply-To: <20140805094957.GB24619@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/8/5 17:49, Michael S. Tsirkin wrote:
> On Tue, Aug 05, 2014 at 02:29:28PM +0800, Zhangjie (HZ) wrote:
>> Jason is right, the new order is not the cause of network unreachable.
>> Changing order seems not work. After about 40 times, the problem occurs again.
>> Maybe there is other hidden reasons for that.
I modified the code to change the order myself yesterday.
This result is about my code.
> 
> To make sure, you tested the patch that I posted to list:
> "vhost_net: stop guest notifiers after backend"?
> 
> Please confirm.
> 
OK, I will test with your patch "vhost_net: stop guest notifiers after backend".

-- 
Best Wishes!
Zhang Jie
