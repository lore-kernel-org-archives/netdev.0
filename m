From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 1/7] MIPS: Octeon: Fix EIO handling.
Date: Tue, 12 Jan 2010 05:43:13 -0800
Message-ID: <20100112134313.GA25052@suse.de>
References: <4B463005.8060505@caviumnetworks.com>
 <1262891106-32146-1-git-send-email-ddaney@caviumnetworks.com>
 <4B4645EE.5050302@ru.mvista.com>
 <4B464977.2090801@caviumnetworks.com>
 <20100107215950.GA24672@suse.de>
 <20100112113619.GA26806@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@caviumnetworks.com>,
	Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35049 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab0ALN5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 08:57:52 -0500
Content-Disposition: inline
In-Reply-To: <20100112113619.GA26806@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 12:36:19PM +0100, Ralf Baechle wrote:
> On Thu, Jan 07, 2010 at 01:59:50PM -0800, Greg KH wrote:
> 
> > >>> If an interrupt handler disables interrupts, the EOI function will
> > >>> just reenable them.  This will put us in an endless loop when the
> > >>> upcoming Ethernet driver patches are applied.
> > >>>
> > >>> Only reenable the interrupt on EOI if it is not IRQ_DISABLED.  This
> > >>> requires that the EIO function be separate from the ENABLE function.
> > >>> We also rename the ACK functions to correspond with their function.
> > >>>
> > >>> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
> > >>>   
> > >>
> > >>   I guess the subject should read "EIO", not "EIO"...
> > >>
> > >
> > > Indeed.  The compiler didn't catch that one.
> > >
> > > Perhaps Ralf can fix it if he merges it, otherwise I can resubmit with 
> > > corrected spelling.
> > 
> > I can change it when merging, don't worry about it.
> 
> This is a driver specific to a specific MIPS platform so I think this
> series should be merged via the MIPS tree and assuming Greg is ok with that
> I have merged this into my tree.

No objection from me at all, merge away :)

thanks,

greg k-h
