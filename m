From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 1/5] vhost: split out ring head fetching
 logic
Date: Mon, 25 Sep 2017 10:03:14 +0800
Message-ID: <5ff7d603-124e-75f1-38fa-9984b194af82@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-2-git-send-email-jasowang@redhat.com>
 <20170922083157.GA9243@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kvm@vger.kernel.org
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922083157.GA9243@stefanha-x1.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月22日 16:31, Stefan Hajnoczi wrote:
> On Fri, Sep 22, 2017 at 04:02:31PM +0800, Jason Wang wrote:
>> +/* This looks in the virtqueue and for the first available buffer, and converts
>> + * it to an iovec for convenient access.  Since descriptors consist of some
>> + * number of output then some number of input descriptors, it's actually two
>> + * iovecs, but we pack them into one and note how many of each there were.
>> + *
>> + * This function returns the descriptor number found, or vq->num (which is
>> + * never a valid descriptor number) if none was found.  A negative code is
>> + * returned on error. */
>> +int __vhost_get_vq_desc(struct vhost_virtqueue *vq,
>> +			struct iovec iov[], unsigned int iov_size,
>> +			unsigned int *out_num, unsigned int *in_num,
>> +			struct vhost_log *log, unsigned int *log_num,
>> +			__virtio16 head)
> [...]
>> +int vhost_get_vq_desc(struct vhost_virtqueue *vq,
>> +		      struct iovec iov[], unsigned int iov_size,
>> +		      unsigned int *out_num, unsigned int *in_num,
>> +		      struct vhost_log *log, unsigned int *log_num)
> Please document vhost_get_vq_desc().
>
> Please also explain the difference between __vhost_get_vq_desc() and
> vhost_get_vq_desc() in the documentation.

Right, will document this in next version.

Thanks
