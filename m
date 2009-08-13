From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 13 Aug 2009 11:45:13 +0300
Message-ID: <20090813084512.GA4401@redhat.com>
References: <cover.1249930169.git.mst@redhat.com> <20090810185340.GC13924@redhat.com> <200908121903.22325.arnd@arndb.de> <20090812172141.GA29966@redhat.com> <4A83167E.2080701@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753661AbZHMIrI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A83167E.2080701@codemonkey.ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 12, 2009 at 02:22:38PM -0500, Anthony Liguori wrote:
> Michael S. Tsirkin wrote:
>>>
>>> We discussed this before, and I still think this could be directly derived
>>> from struct virtqueue, in the same way that vring_virtqueue is derived from
>>> struct virtqueue.
>>>     
>>
>> I prefer keeping it simple. Much of abstraction in virtio is due to the
>> fact that it needs to work on top of different hardware emulations:
>> lguest,kvm, possibly others in the future.  vhost is always working on
>> real hardware, using eventfd as the interface, so it does not need that.
>>   
>
> Actually, vhost may not always be limited to real hardware.

Yes, any ethernet device will do. What I mean is that vhost does not
deal with emulation at all. All setup is done in userspace.

>
> We may on day use vhost as the basis of a driver domain.  There's quite  
> a lot of interest in this for networking.

You can use veth for this. This works today.

> At any rate, I'd like to see performance results before we consider  
> trying to reuse virtio code.
> 
> Regards,
>
> Anthony Liguori
