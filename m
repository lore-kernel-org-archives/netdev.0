From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 08:48:49 +0300
Message-ID: <4A8B9241.20300@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818165139.GC19846@redhat.com> <4A8B8F4E.80207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751406AbZHSFsr@vger.kernel.org>
In-Reply-To: <4A8B8F4E.80207@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/2009 08:36 AM, Gregory Haskins wrote:
>> If virtio net in guest could be improved instead, everyone would
>> benefit.
>>      
> So if I whip up a virtio-net backend for vbus with a PCI compliant
> connector, you are happy?
>    

This doesn't improve virtio-net in any way.

>> I am doing this, and I wish more people would join.  Instead,
>> you change ABI in a incompatible way.
>>      
> Only by choice of my particular connector.  The ABI is a function of the
> connector design.  So one such model is to terminate the connector in
> qemu, and surface the resulting objects as PCI devices.  I choose not to
> use this particular design for my connector that I am pushing upstream
> because I am of the opinion that I can do better by terminating it in
> the guest directly as a PV optimized bus.  However, both connectors can
> theoretically coexist peacefully.
>    

virtio already supports this model; see lguest and s390.  Transporting 
virtio over vbus and vbus over something else doesn't gain anything over 
directly transporting virtio over that something else.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
