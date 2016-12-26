From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 0/9] several fixups for virtio-net XDP
Date: Mon, 26 Dec 2016 10:39:18 +0800
Message-ID: <7163995d-9717-6bf5-3b86-a948e625a927@redhat.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
 <585D5A71.4010106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52964 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751304AbcLZCjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Dec 2016 21:39:25 -0500
In-Reply-To: <585D5A71.4010106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年12月24日 01:10, John Fastabend wrote:
> On 16-12-23 06:37 AM, Jason Wang wrote:
>> Merry Xmas and a Happy New year to all:
>>
>> This series tries to fixes several issues for virtio-net XDP which
>> could be categorized into several parts:
>>
>> - fix several issues during XDP linearizing
>> - allow csumed packet to work for XDP_PASS
>> - make EWMA rxbuf size estimation works for XDP
>> - forbid XDP when GUEST_UFO is support
>> - remove big packet XDP support
>> - add XDP support or small buffer
>>
>> Please see individual patches for details.
>>
>> Thanks
>>
>> Jason Wang (9):
>>    virtio-net: remove the warning before XDP linearizing
>>    virtio-net: correctly xmit linearized page on XDP_TX
>>    virtio-net: fix page miscount during XDP linearizing
>>    virtio-net: correctly handle XDP_PASS for linearized packets
>>    virtio-net: unbreak csumed packets for XDP_PASS
>>    virtio-net: make rx buf size estimation works for XDP
>>    virtio-net: forbid XDP when VIRTIO_NET_F_GUEST_UFO is support
>>    virtio-net: remove big packet XDP codes
>>    virtio-net: XDP support for small buffers
>>
>>   drivers/net/virtio_net.c | 172 ++++++++++++++++++++++++++++-------------------
>>   1 file changed, 102 insertions(+), 70 deletions(-)
>>
> Thanks a lot Jason. The last piece that is needed is support to
> complete XDP support is to get the adjust_head part correct. I'll
> send out a patch in a bit but will need to merge it on top of this
> set.
>
> .John

Yes, glad to see the your patch.

Thanks.
