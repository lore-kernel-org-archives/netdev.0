From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: question about ixgbevf/ixgbevf_main.c
Date: Tue, 7 Jan 2014 16:44:53 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1401071643340.2094@hadrien>
References: <alpine.DEB.2.10.1401071542370.2094@hadrien> <52CC2066.1030303@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <julia.lawall@lip6.fr>, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:31009
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752890AbaAGPpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 10:45:15 -0500
In-Reply-To: <52CC2066.1030303@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Jan 2014, Alexander Duyck wrote:

> A VF isn't a real device so it shouldn't really have the concept of a
> power state.  The power state for the device is controlled via the PF.
> I suspect the fact that ixgbevf is modifying power state on resume is
> likely a bug.

Thanks for the information, which is very helpful.  Should I submit a
patch to remove it in the resume function?  I don't have the ability ot
test it, though.

julia

>
> Thanks,
>
> Alex
>
> On 01/07/2014 06:46 AM, Julia Lawall wrote:
> > I was wondering why ixgbevf_suspend doesn't call pci_set_power_state?  It
> > is called in the corresponding resume function, and most other PCI drivers
> > with a suspend functyion also call it in suspend.
> >
> > thanks,
> > julia
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>
>
