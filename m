From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe in kernel driver question
Date: Wed, 4 Feb 2009 11:28:50 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0902041121030.4348@ppwaskie-MOBL2.amr.corp.intel.com>
References: <49832695.7020802@itcare.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47957 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751677AbZBDT27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 14:28:59 -0500
In-Reply-To: <49832695.7020802@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have question about ixgbe in kernel driver compared to ixgbe driver 
> that is on sourceforge
> http://sourceforge.net/project/showfiles.php?group_id=42302&package_id=247088
> 
> What is difference between this drivers ?
> and does driver in kernel 2.6.28.2

These drivers should be relatively kept in sync.  We release our new 
software to SourceForge first, since that is an on-demand push from Intel.  
The upstream driver usually has the necessary patches in the queue for the 
next kernel, but due to hardware release schedules and kernel release 
schedules not aligning most of the time, there will be differences.

Now these drivers are not intended to be identical.  One main difference, 
for example, is the upstream driver has no module option support.  The 
SourceForge driver does support some module options.

> Or this driver have different versions releases ? with different changes 
> that are made in kernel tree network drivers
> 
> because i have problems with in kernel ixgbe drivers that i can compare 
> to some fixes that are made in:
> 1.3.31.5 driver on e1000 site
> http://sourceforge.net/project/shownotes.php?release_id=611160&group_id=42302
> 
> i think about this fix:
> 
> cpu utilization fix for MSI and legacy interrupts in kernels with CONFIG_NETDEVICES_MULTIQUEUE enabled but default (non multiqueue) aware qdisc loaded

Yes.  These fixes are already queued or accepted for the next version of 
the kernel driver.  The bottom line is we, Intel, own the SourceForge 
driver and its release schedules.  The Linux community ultimately owns the 
in-kernel driver and those release schedules, so there will almost always 
be differences.

I hope this helps,

-PJ Waskiewicz
peter.p.waskiewicz.jr@intel.com
