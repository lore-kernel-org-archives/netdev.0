From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/14][pull request] Intel Wired LAN Driver
 Updates
Date: Fri, 14 Mar 2014 22:19:06 -0400 (EDT)
Message-ID: <20140314.221906.1870253105262648120.davem@davemloft.net>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754810AbaCOCTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 22:19:08 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Mar 2014 16:34:21 -0700

> This series contains updates to igb, i40e and i40evf.
> 
> I provide a code comment fix which David Miller noticed in the last
> series of patches I submitted.
> 
> Shannon provides a patch to cleanup the NAPI structs when deleting the
> netdev.
> 
> Anjali provides several patches for i40e, first fixes a bug in the update
> filter logic which was causing a kernel panic.  Then provides a fix to
> rename an error bit to correctly indicate the error.  Adds a definition
> for a new state variable to keep track of features automatically disabled
> due to hardware resource limitations versus user enforced feature disabled.
> Anjali provides a patch to add code to handle when there is a filter
> programming error due to a full table, which also resolves a previous
> compile warning about an unused "*pf" variable introduced in the last i40e
> series patch submission.
> 
> Jesse provides three i40e patches to cleanup strings to make more
> consistent and to align with other Intel drivers.
> 
> Akeem cleans up a misleading function header comment for i40e.
> 
> Mitch provides a fix for i40e/i40evf to use the correctly reported number
> of MSI-X vectors in the PF an VF.  Then provides a patch to use
> dma_set_mask_and_coherent() which was introduced in v3.13 and simplifies
> the DMA mapping code a bit.
> 
> v2:
> - dropped the 2 ixgbe patches from Emil based on feedback from David Miller,
>   where the 2 fixes should be handled in the net core to fix all drivers

Pulled, thanks Jeff.
