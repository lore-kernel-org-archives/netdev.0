From: Avi Kivity <avi@qumranet.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Tue, 10 Apr 2007 11:19:52 +0300
Message-ID: <461B48A8.1060904@qumranet.com>
References: <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu>
 <1175728768.12230.593.camel@localhost.localdomain>
 <4614A294.3000607@qumranet.com>
 <1175821357.12230.642.camel@localhost.localdomain>
 <46187F4E.1080807@qumranet.com>
 <1176087018.11664.65.camel@localhost.localdomain>
 <4619E6DC.3010804@qumranet.com>
 <1176111984.11664.90.camel@localhost.localdomain>
 <461A41CA.9080201@qumranet.com> <20070410080729.GB16621@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7BIT
Cc: Rusty Russell <rusty@rustcorp.com.au>, Ingo Molnar <mingo@elte.hu>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout2.012.net.il ([84.95.2.4]:23719 "EHLO mtaout2.012.net.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966107AbXDJIkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 04:40:33 -0400
Received: from firebolt.argo.co.il ([80.178.163.252])
 by i_mtaout2.012.net.il (HyperSendmail v2004.12)
 with ESMTP id <0JG900BJ5WVAYTT0@i_mtaout2.012.net.il> for
 netdev@vger.kernel.org; Tue, 10 Apr 2007 11:28:22 +0300 (IDT)
In-reply-to: <20070410080729.GB16621@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Apr 09, 2007 at 04:38:18PM +0300, Avi Kivity (avi@qumranet.com) wrote:
>   
>>> But I don't get this "we can enhance the kernel but not userspace" vibe
>>> 8(
>>>  
>>>       
>> I've been waiting for network aio since ~2003.  If it arrives in the 
>> next few days, I'm all for it; much more than kvm can use it 
>> profitably.  But I'm not going to write that interface myself.
>>     
>
> Hmm, you missed at least two implementations of network aio in the 
> previous year, and now with syslets we can have third one.
>   

I meant, network aio in the mainline kernel.  I am aware of the various
out-of-tree implementations.

> But it looks from this discussion, that it will not prevent from
> changing in-kernel driver - place a hook into skb allocation path and
> allocate data from opposing memory - get pages from another side and put
> them into fragments, then copy headers into skb->data.
>   

I don't understand this (opposing memory, another side?).  Can you
elaborate?

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

