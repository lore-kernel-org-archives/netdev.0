From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 16:07:09 +0300
Message-ID: <49D4B87D.2000202@redhat.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D4B4A3.5070008@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Rusty Russell wrote:
>   
>> On Thursday 02 April 2009 21:36:07 Gregory Haskins wrote:
>>   
>>     
>>> You do not need to know when the packet is copied (which I currently
>>> do).  You only need it for zero-copy (of which I would like to support,
>>> but as I understand it there are problems with the reliability of proper
>>> callback (i.e. skb->destructor).
>>>     
>>>       
>> But if you have a UP guest,
>>     
>
> I assume you mean UP host ;)
>
>   

I think Rusty did mean a UP guest, and without schedule-and-forget.

> Hmm..well I was hoping to be able to work with you guys to make my
> proposal fit this role.  If there is no interest in that, I hope that my
> infrastructure itself may still be considered for merging (in *some*
> tree, not -kvm per se) as I would prefer to not maintain it out of tree
> if it can be avoided.

The problem is that we already have virtio guest drivers going several 
kernel versions back, as well as Windows drivers.  We can't keep 
changing the infrastructure under people's feet.


-- 
error compiling committee.c: too many arguments to function

