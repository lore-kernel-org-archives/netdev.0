From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: question about ixgbevf/ixgbevf_main.c
Date: Tue, 07 Jan 2014 07:42:30 -0800
Message-ID: <52CC2066.1030303@intel.com>
References: <alpine.DEB.2.10.1401071542370.2094@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia.lawall@lip6.fr>, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57704 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbaAGPmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 10:42:31 -0500
In-Reply-To: <alpine.DEB.2.10.1401071542370.2094@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A VF isn't a real device so it shouldn't really have the concept of a
power state.  The power state for the device is controlled via the PF.
I suspect the fact that ixgbevf is modifying power state on resume is
likely a bug.

Thanks,

Alex

On 01/07/2014 06:46 AM, Julia Lawall wrote:
> I was wondering why ixgbevf_suspend doesn't call pci_set_power_state?  It
> is called in the corresponding resume function, and most other PCI drivers
> with a suspend functyion also call it in suspend.
> 
> thanks,
> julia
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
