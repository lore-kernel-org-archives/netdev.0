From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] vhost-net: switch to smp barriers
Date: Sun, 07 Feb 2010 11:56:14 +0200
Message-ID: <4B6E8E3E.30705@redhat.com>
References: <20100201172101.GA10900@redhat.com> <4B6E8B05.8070607@redhat.com> <20100207094441.GA20271@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100207094441.GA20271@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2010 11:44 AM, Michael S. Tsirkin wrote:
> On Sun, Feb 07, 2010 at 11:42:29AM +0200, Avi Kivity wrote:
>    
>> On 02/01/2010 07:21 PM, Michael S. Tsirkin wrote:
>>      
>>> vhost-net only uses memory barriers to control SMP effects
>>> (communication with userspace potentially running on a different CPU),
>>> so it should use SMP barriers and not mandatory barriers for memory
>>> access ordering, as suggested by Documentation/memory-barriers.txt
>>>
>>>
>>>        
>> A UP guest running on an SMP host still needs those barriers.
>>      
> Correct. And since vhost net is running host-side, smp_XX
> barriers will do exactly the right thing, right?
>    

Right, of course.  Mixed up virtio and vhost.

-- 
error compiling committee.c: too many arguments to function
