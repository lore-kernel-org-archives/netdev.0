From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/14] Intel Wired LAN Driver Updates
Date: Fri, 21 Feb 2014 12:39:47 -0500 (EST)
Message-ID: <20140221.123947.1401040415929829018.davem@davemloft.net>
References: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933162AbaBURjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 12:39:49 -0500
In-Reply-To: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Thu, 20 Feb 2014 19:29:04 -0800

> This series contains updates to i40e and (mostly to) i40evf.
> 
> Mitch provides most the work for this series.  For the vf driver he
> requests a reset on a tx hang, removes vlan filtes on close since we
> already remove the MAC filters, fixes some crashes, gets rid of PCI DAC
> as it does not mean much on virtualized PCIe parts, skips assigning the
> device name that just gets renamed anyway, stores the descriptor ring
> size in a manner that allows the use of common tx and rx code with the
> PF driver and makes a handful of cosmetic fixes.  For i40e he removes
> a delay left over from debugging and changes a do/while loop to a for
> loop to avoid hitting another delay each time.
> 
> Catherine fixes inconsistent MSI and MSI-X messages and bumps the
> driver version.
> 
> v2: Removed unnecessary periods and redundant OOM message.

Series applied, thanks Aaron.
