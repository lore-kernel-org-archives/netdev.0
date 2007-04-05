From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 5 Apr 2007 12:26:56 +0200
Message-ID: <20070405102656.GA5595@elte.hu>
References: <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com> <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu> <1175728768.12230.593.camel@localhost.localdomain> <20070405093033.GC25448@elte.hu> <4614C846.7070605@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56482 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966017AbXDEK1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 06:27:12 -0400
Content-Disposition: inline
In-Reply-To: <4614C846.7070605@qumranet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Avi Kivity <avi@qumranet.com> wrote:

> > so right now the only option for a clean codebase is the KVM 
> > in-kernel code.
> 
> I strongly disagree with this.

are you disagreeing with my statement that the KVM kernel-side code is 
the only clean codebase here? To me this is a clear fact :)

I only pointed out that the only clean codebase at the moment is the KVM 
in-kernel code - i did not make the argument (at all) that every new 
piece of KVM code should be done in the kernel. That would be stupid - 
do you think i'd advocate for example moving command line argument 
parsing into the kernel?

and as i said in the mail: "the kernel _is_ the best place to do this 
particular stuff".

	Ingo
