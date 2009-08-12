From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 12 Aug 2009 14:22:38 -0500
Message-ID: <4A83167E.2080701@codemonkey.ws>
References: <cover.1249930169.git.mst@redhat.com> <20090810185340.GC13924@redhat.com> <200908121903.22325.arnd@arndb.de> <20090812172141.GA29966@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753518AbZHLTWn@vger.kernel.org>
In-Reply-To: <20090812172141.GA29966@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin wrote:
>>
>> We discussed this before, and I still think this could be directly derived
>> from struct virtqueue, in the same way that vring_virtqueue is derived from
>> struct virtqueue.
>>     
>
> I prefer keeping it simple. Much of abstraction in virtio is due to the
> fact that it needs to work on top of different hardware emulations:
> lguest,kvm, possibly others in the future.  vhost is always working on
> real hardware, using eventfd as the interface, so it does not need that.
>   

Actually, vhost may not always be limited to real hardware.

We may on day use vhost as the basis of a driver domain.  There's quite 
a lot of interest in this for networking.

At any rate, I'd like to see performance results before we consider 
trying to reuse virtio code.

Regards,

Anthony Liguori
