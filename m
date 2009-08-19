From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	 vbus_driver
 objects
Date: Wed, 19 Aug 2009 10:13:57 +0300
Message-ID: <4A8BA635.9010902@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818165139.GC19846@redhat.com> <4A8B8F4E.80207@gmail.com> <4A8B9241.20300@redhat.com> <4A8B66280200005A00052A54@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	alacrityvm-devel@lists.sourceforge.net,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751476AbZHSHNz@vger.kernel.org>
In-Reply-To: <4A8B66280200005A00052A54@sinclair.provo.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/2009 09:40 AM, Gregory Haskins wrote:
>
>    
>>> So if I whip up a virtio-net backend for vbus with a PCI compliant
>>> connector, you are happy?
>>>
>>>        
>> This doesn't improve virtio-net in any way.
>>      
> Any why not?  (Did you notice I said "PCI compliant", i.e. over virtio-pci)
>    

Because virtio-net will have gained nothing that it didn't have before.




>> virtio already supports this model; see lguest and s390.  Transporting
>> virtio over vbus and vbus over something else doesn't gain anything over
>> directly transporting virtio over that something else.
>>      
> This is not what I am advocating.
>
>    

What are you advocating?  As far as I can tell your virtio-vbus 
connector plus the vbus-kvm connector is just that.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
