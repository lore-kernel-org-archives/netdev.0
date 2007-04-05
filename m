From: Avi Kivity <avi@qumranet.com>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 05 Apr 2007 14:26:25 +0300
Message-ID: <4614DCE1.70905@qumranet.com>
References: <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu> <1175728768.12230.593.camel@localhost.localdomain> <20070405093033.GC25448@elte.hu> <4614C846.7070605@qumranet.com> <20070405102656.GA5595@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from il.qumranet.com ([82.166.9.18]:51555 "EHLO il.qumranet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753016AbXDEL01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 07:26:27 -0400
In-Reply-To: <20070405102656.GA5595@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Avi Kivity <avi@qumranet.com> wrote:
>
>   
>>> so right now the only option for a clean codebase is the KVM 
>>> in-kernel code.
>>>       
>> I strongly disagree with this.
>>     
>
> are you disagreeing with my statement that the KVM kernel-side code is 
> the only clean codebase here? To me this is a clear fact :)
>   

No, I agree with that.  I just disagree with choosing to put the *pic 
code (or other code) into the kernel on *that* basis.  The selection 
should be on design/performance issues alone, *not* the state of 
existing code.

> I only pointed out that the only clean codebase at the moment is the KVM 
> in-kernel code - i did not make the argument (at all) that every new 
> piece of KVM code should be done in the kernel. That would be stupid - 
> do you think i'd advocate for example moving command line argument 
> parsing into the kernel?
>   

No.  But the difference in cruftiness between kvm and qemu code should 
not enter into the discussion of where to do things.

> and as i said in the mail: "the kernel _is_ the best place to do this 
> particular stuff".
>   

I agree with this, maybe for different reasons.


-- 
error compiling committee.c: too many arguments to function

