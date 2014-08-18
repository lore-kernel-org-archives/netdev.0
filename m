From: Jason Wang <jasowang@redhat.com>
Subject: Re: Query: Is it possible  to lose interrupts between vhost and virtio_net
 during migration?
Date: Mon, 18 Aug 2014 13:23:11 +0800
Message-ID: <53F18DBF.4090208@redhat.com>
References: <20140731143725.GA3875@redhat.com> <53DB705F.2000405@redhat.com> <53DB76A9.8010305@redhat.com> <53E079C8.7050700@huawei.com> <20140805094957.GB24619@redhat.com> <53E0CAA4.8010303@huawei.com> <53E37561.5060302@huawei.com> <53EC78D8.6070405@redhat.com> <20140814100231.GB30944@redhat.com> <53ED76A4.4090005@redhat.com> <20140817102233.GC21622@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Zhangjie (HZ)" <zhangjie14@huawei.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, qinchuanyu@huawei.com,
	liuyongan@huawei.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21531 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762AbaHRFXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 01:23:23 -0400
In-Reply-To: <20140817102233.GC21622@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2014 06:22 PM, Michael S. Tsirkin wrote:
> On Fri, Aug 15, 2014 at 10:55:32AM +0800, Jason Wang wrote:
>>>>> I wonder if k->set_guest_notifiers should be called after "hdev->started = true;" in vhost_dev_start.
>>>> Michael, can we just remove those assertions? Since you may want to set
>>>> guest notifiers before starting the backend.
>>> Which assertions?
>> I mean assert(hdev->started) in vhost.c. Your patch may hit them.
> I don't follow, but since my patch doesn't help anyway, pls go ahead
> and post your idea in form of a patch, will be clearer and can
> be tested.

Ok, will post the patch.
