From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for		 vbus_driver
 objects
Date: Wed, 19 Aug 2009 14:49:38 +0300
Message-ID: <4A8BE6D2.3090107@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818165139.GC19846@redhat.com> <4A8B8F4E.80207@gmail.com> <4A8B9241.20300@redhat.com> <4A8B66280200005A00052A54@sinclair.provo.novell.com> <4A8BA635.9010902@redhat.com> <4A8BAC750200005A00052A83@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	alacrityvm-devel@lists.sourceforge.net,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34343 "EHLO mx2.redhat.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751494AbZHSLuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 07:50:09 -0400
In-Reply-To: <4A8BAC750200005A00052A83@sinclair.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2009 02:40 PM, Gregory Haskins wrote:
>
>>>>> So if I whip up a virtio-net backend for vbus with a PCI compliant
>>>>> connector, you are happy?
>>>>>
>>>>>
>>>>>            
>>>> This doesn't improve virtio-net in any way.
>>>>
>>>>          
>>> Any why not?  (Did you notice I said "PCI compliant", i.e. over virtio-pci)
>>>
>>>        
>> Because virtio-net will have gained nothing that it didn't have before.
>>      
> ??
>
> *) ABI is virtio-pci compatible, as you like
>    

That's not a gain, that's staying in the same place.

> *) fast-path is in-kernel, as we all like
>    

That's not a gain as we have vhost-net (sure, in development, but your 
proposed backend isn't even there yet).

> *) model is in vbus so it would work in all environments that vbus supports.
>    

The ABI can be virtio-pci compatible or it can be vbus-comaptible.  How 
can it be both?  The ABIs are different.

Note that if you had submitted a virtio-net backend I'd have asked you 
to strip away all the management / bus layers and we'd have ended up 
with vhost-net.

>>>> virtio already supports this model; see lguest and s390.  Transporting
>>>> virtio over vbus and vbus over something else doesn't gain anything over
>>>> directly transporting virtio over that something else.
>>>>
>>>>          
>>> This is not what I am advocating.
>>>
>>>
>>>        
>> What are you advocating?  As far as I can tell your virtio-vbus
>> connector plus the vbus-kvm connector is just that.
>>      
> I wouldn't classify it anything like that, no.  Its just virtio over vbus.
>    

We're in a loop.  Doesn't virtio over vbus need a virtio-vbus 
connector?  and doesn't vbus need a connector to talk to the hypervisor?

-- 
error compiling committee.c: too many arguments to function

