From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 4/4] net, virtio_net: replace the magic value
Date: Mon, 18 Nov 2013 20:26:29 +0800
Message-ID: <CAEH94Lj4hCtcxvibO9RCB1+sbn=+xR2bO7CbCkRyx9BCJFGaOA@mail.gmail.com>
References: <1384764380-16832-1-git-send-email-zwu.kernel@gmail.com>
	<20131118095043.GA3470@redhat.com>
	<CAEH94Ljbu-gJ3SCHYErNEPucV=rR9PHz5COrOp3B-iw+db=LDQ@mail.gmail.com>
	<20131118101517.GA3559@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, QEMU Developers <qemu-devel@nongnu.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	linux-kernel mlist <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36017 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288Ab3KRM0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 07:26:30 -0500
In-Reply-To: <20131118101517.GA3559@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 6:15 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, Nov 18, 2013 at 06:07:45PM +0800, Zhi Yong Wu wrote:
>> On Mon, Nov 18, 2013 at 5:50 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> > On Mon, Nov 18, 2013 at 04:46:20PM +0800, Zhi Yong Wu wrote:
>> >> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> >>
>> >> It is more appropriate to use # of queue pairs currently used by
>> >> the driver instead of a magic value.
>> >>
>> >> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> >
>> > I don't mind, but driver should be submitted separately
>> > from qemu patches. As it is only patch 4/4 made it to netdev.
>> ok, i will sent v2. By the way, can you help take a look at the
>> following patches?
>
> Will do.
>
>> Maybe i can send their v2 together.
>
> Please don't, these seem to be completely unrelated.
OK, i will send it separately.
>
>> [PATCH 1/3] vhost: remove the dead branch
>> [PATCH 2/3] vhost: adjust vhost_dev_init() to be void
>> [PATCH 3/3] vhost: fix the wrong log descriptions
>>
>>
>> >
>> >> ---
>> >>  drivers/net/virtio_net.c |    4 ++--
>> >>  1 files changed, 2 insertions(+), 2 deletions(-)
>> >>
>> >> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> >> index cdc7c90..e0cb2d1 100644
>> >> --- a/drivers/net/virtio_net.c
>> >> +++ b/drivers/net/virtio_net.c
>> >> @@ -1619,8 +1619,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>> >>       if (err)
>> >>               goto free_stats;
>> >>
>> >> -     netif_set_real_num_tx_queues(dev, 1);
>> >> -     netif_set_real_num_rx_queues(dev, 1);
>> >> +     netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
>> >> +     netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
>> >>
>> >>       err = register_netdev(dev);
>> >>       if (err) {
>> >> --
>> >> 1.7.6.5
>> >>
>>
>>
>>
>> --
>> Regards,
>>
>> Zhi Yong Wu



-- 
Regards,

Zhi Yong Wu
