From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/7] MIPS: Octeon: Fix EIO handling.
Date: Tue, 12 Jan 2010 12:36:19 +0100
Message-ID: <20100112113619.GA26806@linux-mips.org>
References: <4B463005.8060505@caviumnetworks.com>
 <1262891106-32146-1-git-send-email-ddaney@caviumnetworks.com>
 <4B4645EE.5050302@ru.mvista.com>
 <4B464977.2090801@caviumnetworks.com>
 <20100107215950.GA24672@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@caviumnetworks.com>,
	Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:44439 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab0ALLga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 06:36:30 -0500
Received: from localhost.localdomain ([127.0.0.1]:39203 "EHLO h5.dl5rb.org.uk"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S1492614Ab0ALLg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Jan 2010 12:36:28 +0100
Content-Disposition: inline
In-Reply-To: <20100107215950.GA24672@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 01:59:50PM -0800, Greg KH wrote:

> >>> If an interrupt handler disables interrupts, the EOI function will
> >>> just reenable them.  This will put us in an endless loop when the
> >>> upcoming Ethernet driver patches are applied.
> >>>
> >>> Only reenable the interrupt on EOI if it is not IRQ_DISABLED.  This
> >>> requires that the EIO function be separate from the ENABLE function.
> >>> We also rename the ACK functions to correspond with their function.
> >>>
> >>> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
> >>>   
> >>
> >>   I guess the subject should read "EIO", not "EIO"...
> >>
> >
> > Indeed.  The compiler didn't catch that one.
> >
> > Perhaps Ralf can fix it if he merges it, otherwise I can resubmit with 
> > corrected spelling.
> 
> I can change it when merging, don't worry about it.

This is a driver specific to a specific MIPS platform so I think this
series should be merged via the MIPS tree and assuming Greg is ok with that
I have merged this into my tree.

  Ralf
