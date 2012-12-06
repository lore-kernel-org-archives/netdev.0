From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87):
 Section mismatch in reference from the function sundance_probe1() to the
 variable .devinit.rodata:sundance_pci_tbl
Date: Thu, 6 Dec 2012 10:16:46 +0800
Message-ID: <20121206021646.GA8591@localhost>
References: <50be77ca.95imDYp6GlyHjRuw%fengguang.wu@intel.com>
 <CAOJe8K3xBAuhVND-9dJgSxShhpHQ3zko=bE2CNrAKVa-gvDouA@mail.gmail.com>
 <20121205.125006.830180895260845549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kda@linux-powerpc.org, wfp5p@virginia.edu, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9338 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880Ab2LFCRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 21:17:46 -0500
Content-Disposition: inline
In-Reply-To: <20121205.125006.830180895260845549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2012 at 12:50:06PM -0500, David Miller wrote:
> From: Denis Kirjanov <kda@linux-powerpc.org>
> Date: Wed, 5 Dec 2012 11:12:32 +0300
> 
> > I"ll fix it.
> 
> You can't.
> 
> It's only going to get fixed by a change in Greg KH's device tree
> which updates the PCI table macros to not use __dev* section tags.
> 
> Fengguant, _PLEASE_, as Greg requested, stop reporting these section
> mismatch errors, they aren't helpful and are wasting valuable
> developer time.

Dave, Greg: Sorry for the delay! I've just disabled these section
mismatch warnings against *devinit*.

Thanks,
Fengguang
