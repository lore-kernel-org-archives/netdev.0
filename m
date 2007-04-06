From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Fri, 6 Apr 2007 20:59:18 +0200
Message-ID: <20070406185918.GA14863@elte.hu>
References: <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu> <1175728768.12230.593.camel@localhost.localdomain> <20070405093033.GC25448@elte.hu> <4614C846.7070605@qumranet.com> <20070405102656.GA5595@elte.hu> <4614DCE1.70905@qumranet.com> <20070405113655.GA21542@elte.hu> <1175822161.12230.652.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:38657 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbXDFS7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 14:59:35 -0400
Content-Disposition: inline
In-Reply-To: <1175822161.12230.652.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Rusty Russell <rusty@rustcorp.com.au> wrote:

> > prototyping new kernel APIs to implement user-space network drivers, 
> > on a crufty codebase is not something that should be done lightly.
> 
> I think you overestimate my radicalism.  I was considering readv() and 
> writev() on the tap device.

ok :-) How would packeting be handled, or would this be alike a raw 
socket in essence, but not in 'peek' but 'filter through' mode? I think 
it's not quite trivial. (but maybe i'm way too radical again :)

	Ingo
