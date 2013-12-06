From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Fri, 06 Dec 2013 14:49:05 -0500 (EST)
Message-ID: <20131206.144905.175368576679118168.davem@davemloft.net>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41872 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757260Ab3LFTtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 14:49:07 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  6 Dec 2013 00:06:13 -0800

> This series contains updates to i40e only.
> 
> Christopher Pau provides a patch to set pf_id based on device and
> function numbers since NICs with ARI enabled can have function
> numbers larger than 8.
> 
> Anjali provides 3 i40e patches to update hardware defines to keep
> in sync with hardware updates.
> 
> Shannon provides the majority of i40e patches, with 7.  First patch
> clears the admin queue head and tail registers during admin queue
> shutdown. Then simplifies the admin queue head-tail-len setups to
> use more virtual registers.  Provides several patches to cleanup
> and fix driver load and reset procedures to make more robust.  Lastly,
> provides an ethtool test for interrupts using the software interrupt.
> 
> Mitch provides some i40e patches which fixes up VF code in the PF
> driver, specifically the number of vectors per VF are reported by the
> hardware does not include vector 0, so we need to account for this
> when checking.  In addition, cleans up debugging messages.
> 
> Kamil provides an i40e patch to fix the diagnostics test by restricting
> the diagnostic test length.

Pulled, thanks a lot Jeff.
