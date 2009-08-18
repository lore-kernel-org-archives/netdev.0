From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Tue, 18 Aug 2009 13:28:40 +0300
Message-ID: <20090818102840.GF13878@redhat.com>
References: <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com> <4A8A7BB9.2020906@redhat.com> <20090818100945.GD13878@redhat.com> <4A8A7EE5.6090209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A8A7EE5.6090209@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 01:13:57PM +0300, Avi Kivity wrote:
> On 08/18/2009 01:09 PM, Michael S. Tsirkin wrote:
>>
>>> mmio and pio don't have this problem since the host can use the address
>>> to locate the destination.
>>>      
>> So userspace could map hypercall to address during setup and tell the
>> host kernel?
>>    
>
> Suppose a nested guest has two devices.  One a virtual device backed by  
> its host (our guest), and one a virtual device backed by us (the real  
> host), and assigned by the guest to the nested guest.  If both devices  
> use hypercalls, there is no way to distinguish between them.

Not sure I understand. What I had in mind is that devices would have to
either use different hypercalls and map hypercall to address during
setup, or pass address with each hypercall.  We get the hypercall,
translate the address as if it was pio access, and know the destination?

> -- 
> error compiling committee.c: too many arguments to function
