From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 05 Apr 2007 09:19:27 +1000
Message-ID: <1175728768.12230.593.camel@localhost.localdomain>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>
	 <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
	 <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
	 <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
	 <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
	 <20070404212103.GA19026@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <aliguori@us.ibm.com>,
	kvm-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47668 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759AbXDDXUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 19:20:16 -0400
In-Reply-To: <20070404212103.GA19026@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 23:21 +0200, Ingo Molnar wrote:
> * Anthony Liguori <aliguori@us.ibm.com> wrote:
> 
> > But why is it a good thing to do PV drivers in the kernel?  You lose 
> > flexibility and functionality to gain performance. [...]
> 
> in Linux a kernel-space network driver can still be tunneled over 
> user-space code, and hence you can add arbitrary add-on functionality 
> (and thus have flexibility), without slowing down the common case (which 
> would be to tunnel the guest's network traffic into the firewall rules 
> of the kernel. No need to touch user-space for any of that).

You didn't quote Anthony's point about "it's more about there not being
good enough userspace interfaces to do network IO."

It's easier to write a kernel-space network driver, but it's not
obviously the right thing to do until we can show that an efficient
packet-level userspace interface isn't possible.  I don't think that's
been done, and it would be interesting to try.

Cheers,
Rusty.



