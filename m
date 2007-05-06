From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Sat, 05 May 2007 17:15:02 -0700
Message-ID: <1178410502.4859.46.camel@dell>
References: <20070504.194207.82054727.davem@davemloft.net>
 <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
 <20070504.204700.24899658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2316 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753999AbXEEX1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2007 19:27:41 -0400
In-Reply-To: <20070504.204700.24899658.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-04 at 20:47 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 4 May 2007 19:50:10 -0700
> 
> > In a small number of cases, we really get a ton of spurious interrupts.
> > We have even seen the kernel shutting off IRQ7 because of too many
> > unclaimed spurious interrupts.
> 
> Ok, that's a big problem.
> 
> In retrospect the read back is only needed on non-MSI
> right?  I guess that'd be ok.
> 
Right, not needed in MSI as MSI is considered an edge interrupt.  I will
resubmit a new patch to just flush the mailbox.

