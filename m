From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Wed, 03 Oct 2012 16:40:06 +0930
Message-ID: <87sj9w2fqp.fsf@rustcorp.com.au>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, avi@redhat.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <87vces2gxq.fsf@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell <rusty@rustcorp.com.au> writes:

> "Michael S. Tsirkin" <mst@redhat.com> writes:
>
>> Thinking about Sasha's patches, we can reduce ring usage
>> for virtio net small packets dramatically if we put
>> virtio net header inline with the data.
>> This can be done for free in case guest net stack allocated
>> extra head room for the packet, and I don't see
>> why would this have any downsides.
>
> I've been wanting to do this for the longest time... but...
>
>> Even though with my recent patches qemu
>> no longer requires header to be the first s/g element,

Breaks for me; see why I hate bug features?  Now we'd need another
one...

qemu-system-i386: virtio: trying to map MMIO memory

Please try my patch.

Cheers,
Rusty.
