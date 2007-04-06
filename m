From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Fri, 06 Apr 2007 11:16:01 +1000
Message-ID: <1175822161.12230.652.camel@localhost.localdomain>
References: <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
	 <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
	 <20070404212103.GA19026@elte.hu>
	 <1175728768.12230.593.camel@localhost.localdomain>
	 <20070405093033.GC25448@elte.hu> <4614C846.7070605@qumranet.com>
	 <20070405102656.GA5595@elte.hu> <4614DCE1.70905@qumranet.com>
	 <20070405113655.GA21542@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41616 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767468AbXDFBQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 21:16:20 -0400
In-Reply-To: <20070405113655.GA21542@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-04-05 at 13:36 +0200, Ingo Molnar wrote:
> prototyping new kernel APIs to implement user-space network drivers, on 
> a crufty codebase is not something that should be done lightly.

I think you overestimate my radicalism.  I was considering readv() and
writev() on the tap device.

Qemu's infrastructure may hurt kvm here, but lguest won't be able to use
that excuse.

> track issue for the *PIC question at 
> hand. PICs are not network devices, they are essential platform 
> components and almost an extended part of the CPU.)

Definitely, I'm only interested in stealing^H^H^Hsharing KVM devices.
The subject is now deeply misleading 8(

Cheers,
Rusty.

