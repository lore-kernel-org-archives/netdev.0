From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 08/10] vsock/virtio: mark an internal function static
Date: Mon, 12 Dec 2016 09:56:43 +0800
Message-ID: <6ca97f10-338f-ef7c-d07c-943e44ef7f23@redhat.com>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
 <1481038106-24899-9-git-send-email-mst@redhat.com>
 <487d3d4a-7a53-cb45-2cfd-5eb68d9b73f0@redhat.com>
 <20161208162458-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        Stefan Hajnoczi <stefanha@redhat.com>,
        "David S. Miller" <davem@davemloft.net>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208162458-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年12月08日 22:25, Michael S. Tsirkin wrote:
> On Wed, Dec 07, 2016 at 12:21:22PM +0800, Jason Wang wrote:
>>
>> On 2016年12月06日 23:41, Michael S. Tsirkin wrote:
>>> virtio_transport_alloc_pkt is only used locally, make it static.
>>>
>>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>>> ---
>>>    net/vmw_vsock/virtio_transport_common.c | 2 +-
>>>    1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
>>> index a53b3a1..6120384 100644
>>> --- a/net/vmw_vsock/virtio_transport_common.c
>>> +++ b/net/vmw_vsock/virtio_transport_common.c
>>> @@ -32,7 +32,7 @@ static const struct virtio_transport *virtio_transport_get_ops(void)
>>>    	return container_of(t, struct virtio_transport, transport);
>>>    }
>>> -struct virtio_vsock_pkt *
>>> +static struct virtio_vsock_pkt *
>>>    virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
>>>    			   size_t len,
>>>    			   u32 src_cid,
>> Git grep shows it was used by tracing.
> True but trace_virtio_transport_alloc_pkt is also local to
> virtio_transport_common.c
>

I see, so let's remove the EXPORT_SYMBOL_GPL() too?
