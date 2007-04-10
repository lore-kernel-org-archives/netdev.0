From: Avi Kivity <avi@qumranet.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Tue, 10 Apr 2007 15:17:45 +0300
Message-ID: <461B8069.6070007@qumranet.com>
References: <1175821357.12230.642.camel@localhost.localdomain> <46187F4E.1080807@qumranet.com> <1176087018.11664.65.camel@localhost.localdomain> <4619E6DC.3010804@qumranet.com> <1176111984.11664.90.camel@localhost.localdomain> <461A41CA.9080201@qumranet.com> <20070410080729.GB16621@2ka.mipt.ru> <461B48A8.1060904@qumranet.com> <20070410085825.GA20004@2ka.mipt.ru> <461B7334.8090807@qumranet.com> <20070410115035.GA2247@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Ingo Molnar <mingo@elte.hu>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from il.qumranet.com ([82.166.9.18]:33887 "EHLO il.qumranet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965030AbXDJMRr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 08:17:47 -0400
In-Reply-To: <20070410115035.GA2247@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>> This is what Xen does.  It is actually less performant than copying, IIRC.
>>
>> The problem with flipping pages around is that physical addresses are 
>> cached both in the kvm mmu and in the on-chip tlbs, necessitating 
>> expensive page table walks and tlb invalidation IPIs.
>>     
>
> Hmm, I'm not familiar with Xen driver, but similar technique was used
> with zero-copy network sniffer some time ago, substituting userspace
> pages with pages containing skb data was about 25-50% faster than
> copying 1500 bytes in general, and in order of 10 times faster in some
> cases.
>
> Check a link please in case we are talking about different ideas:
> http://marc.info/?l=linux-netdev&m=112262743505711&w=2
>
>   

I don't really understand what you're testing there.  in particular, how 
can the copying time change so dramatically depending on whether you've 
just rebooted or not?



-- 
error compiling committee.c: too many arguments to function

