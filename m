From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 12:03:32 +0300
Message-ID: <49D47F64.3020709@redhat.com>
References: <20090402030935.GA27836@gondor.apana.org.au> <49D45F59.9030100@redhat.com> <20090402085411.GA29967@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>, andi@firstfloor.org,
	ghaskins@novell.com, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761552AbZDBJE2@vger.kernel.org>
In-Reply-To: <20090402085411.GA29967@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 09:46:49AM +0300, Avi Kivity wrote:
>   
>> I don't understand this.  If we had good interfaces, all that userspace  
>> would do is translate guest physical addresses to host physical  
>> addresses, and translate the guest->host protocol to host API calls.  I  
>> don't see anything there that benefits from being in the kernel.
>>
>> Can you elaborate?
>>     
>
> I think Greg has expressed it clearly enough.
>
> At the end of the day, the numbers speak for themselves.  So if
> and when there's a user-space version that achieves the same or
> better results, then I will change my mind :)
>   

Like Anthony said, the problem is with the kernel->user interfaces.  We 
won't have a good user space virtio implementation until that is fixed.

-- 
error compiling committee.c: too many arguments to function
