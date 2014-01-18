From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/7] Intel Wired LAN Driver Updates
Date: Fri, 17 Jan 2014 19:18:01 -0800 (PST)
Message-ID: <20140117.191801.664015483645532953.davem@davemloft.net>
References: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbaARDSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 22:18:02 -0500
In-Reply-To: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Fri, 17 Jan 2014 18:29:58 -0800

> This series contains updates from Emil to ixgbevf.
> 
> He cleans up the code by removing the adapter structure as a
> parameter from multiple functions in favor of using the ixgbevf_ring
> structure and moves hot-path specific statistic int the ring 
> structure for anticipated performance gains.
> 
> He also removes the Tx/Rx counters for checksum offload and adds 
> counters for tx_restart_queue and tx_timeout_count.
> 
> Next he makes it so that the first tx_buffer structure acts as a
> central storage location for most the skb info we are about to
> transmit, then takes advantage of the dma buffer always being
> present in the first descriptor and mapped as single allowing a 
> call to dma_unmap_single which alleviates the need to check for
> DMA mapping in ixgbevf_clean_tx_irq().  
> 
> Finally he merges the ixgbevf_tx_map call and the ixgbevf_tx_queue
> call into a single function.

Series applied, thanks.
