From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 4/4] net,
	virtio_net: replace the magic value
Date: Mon, 18 Nov 2013 18:07:45 +0800
Message-ID: <CAEH94Ljbu-gJ3SCHYErNEPucV=rR9PHz5COrOp3B-iw+db=LDQ@mail.gmail.com>
References: <1384764380-16832-1-git-send-email-zwu.kernel@gmail.com>
	<20131118095043.GA3470@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	linux-kernel mlist <linux-kernel@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20131118095043.GA3470@redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 18, 2013 at 5:50 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, Nov 18, 2013 at 04:46:20PM +0800, Zhi Yong Wu wrote:
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> It is more appropriate to use # of queue pairs currently used by
>> the driver instead of a magic value.
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> I don't mind, but driver should be submitted separately
> from qemu patches. As it is only patch 4/4 made it to netdev.
ok, i will sent v2. By the way, can you help take a look at the
following patches? Maybe i can send their v2 together.
[PATCH 1/3] vhost: remove the dead branch
[PATCH 2/3] vhost: adjust vhost_dev_init() to be void
[PATCH 3/3] vhost: fix the wrong log descriptions


>
>> ---
>>  drivers/net/virtio_net.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index cdc7c90..e0cb2d1 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1619,8 +1619,8 @@ static int virtnet_probe(struct virtio_device *vdev)
>>       if (err)
>>               goto free_stats;
>>
>> -     netif_set_real_num_tx_queues(dev, 1);
>> -     netif_set_real_num_rx_queues(dev, 1);
>> +     netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
>> +     netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
>>
>>       err = register_netdev(dev);
>>       if (err) {
>> --
>> 1.7.6.5
>>



-- 
Regards,

Zhi Yong Wu
