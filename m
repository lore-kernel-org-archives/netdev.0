From: David Boutcher <boutcher@us.ibm.com>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual	network	device	driver.
Date: Tue, 9 May 2006 09:30:53 -0500
Message-ID: <OFE128D80F.BD59DF3E-ON86257169.004F91EA-86257169.004F6870@us.ibm.com>
References: <20060509140027.GD7834@cl.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: chrisw@sous-sol.org, Herbert Xu <herbert@gondor.apana.org.au>,
	ian.pratt@xensource.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:19374 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750997AbWEIOa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 10:30:59 -0400
In-Reply-To: <20060509140027.GD7834@cl.cam.ac.uk>
To: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtualization-bounces@lists.osdl.org wrote on 05/09/2006 09:00:27 AM:
> On Tue, May 09, 2006 at 11:26:03PM +1000, Herbert Xu wrote:
> > Christian Limpach <Christian.Limpach@cl.cam.ac.uk> wrote:
> > > 
> > > Possibly having to page in the process and switching to it would add
> > > to the live migration time.  More importantly, having to install an
> > > additional program in the guest is certainly not very convenient.
> > 
> > Sorry I'm still not convinced.  What's there to stop me from 
suspending
> > my laptop to disk, moving it from port A to port B and resuming it?
> > 
> > Wouldn't I be in exactly the same situation? By the same reasoning 
we'd
> > be adding a gratuitous ARP routine to every single laptop network 
driver.
> 
> It is the same situation except that in the laptop case you don't care
> that reconfiguring your network will take a second or a few.  For live
> migration we're looking at network downtime from as low as 60ms to
> something like 210ms on a busy virtual machine.  I'm not saying that
> a userspace solution wouldn't work but it would probably add a 
measurable
> delay to the network downtime during live migration.

Then make a generic solution.  VMWare supports migration, the Power 
virtualization will get around to it eventually.  All will need something
similar.  So either make a common user-land tool, or (if you insist on
incorrectly driving this into the kernel) add some kind of common hook to
the TCP/IP stack.

Dave Boutcher
IBM Linux Technology Center
