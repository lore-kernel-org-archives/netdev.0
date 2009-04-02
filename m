From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 09:46:49 +0300
Message-ID: <49D45F59.9030100@redhat.com>
References: <20090402030935.GA27836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>, andi@firstfloor.org,
	ghaskins@novell.com, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090402030935.GA27836@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Anthony Liguori <anthony@codemonkey.ws> wrote:
>   
>> That said, I don't think we're bound today by the fact that we're in 
>> userspace.  Rather we're bound by the interfaces we have between the 
>> host kernel and userspace to generate IO.  I'd rather fix those 
>> interfaces than put more stuff in the kernel.
>>     
>
> I'm sorry but I totally disagree with that.  By having our IO
> infrastructure in user-space we've basically given up the main
> advantage of kvm, which is that the physical drivers operate in
> the same environment as the hypervisor.
>   

I don't understand this.  If we had good interfaces, all that userspace 
would do is translate guest physical addresses to host physical 
addresses, and translate the guest->host protocol to host API calls.  I 
don't see anything there that benefits from being in the kernel.

Can you elaborate?

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

