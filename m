From: Phil Oester <kernel@linuxace.com>
Subject: Re: bnx2 probe order change from 2.6.21 -> 2.6.24
Date: Wed, 16 Apr 2008 08:51:01 -0700
Message-ID: <20080416155101.GA26072@linuxace.com>
References: <20080410154401.GA14486@linuxace.com> <20080410184455.GL84358@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: Jim Westfall <jwestfall@surrealistic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:47299
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758319AbYDPPvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 11:51:03 -0400
Content-Disposition: inline
In-Reply-To: <20080410184455.GL84358@surrealistic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2008 at 11:44:55AM -0700, Jim Westfall wrote:
> Phil Oester <kernel@linuxace.com> wrote [04.10.08]:
> > I recently upgraded a Dell Poweredge 1950 from 2.6.21 to 2.6.24, and found
> > that the onboard Broadcom NetXtreme II nics got probed in the reverse order.
> 
> We ran into this issue as well when going from 2.6.20 to 2.6.23 on dell 
> 1950/2950s.
> 
> If you check your dmesg output from your older kernel you should see
> 
> PCI: Dell PowerEdge 1950 detected, enabling pci=bfsort.
> 
> With the newer kernel the code path that triggers the above is removed if 
> you have ACPI enabled in the kernel.

Thanks.  This was caused by commit 08f1c192c3c32797068bfe97738babb3295bbf42
(x86-64: introduce struct pci_sysdata to facilitate sharing of ->sysdata).

I've sent something along to the kernel list.

Phil
