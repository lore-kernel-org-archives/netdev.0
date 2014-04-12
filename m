From: David Miller <davem@davemloft.net>
Subject: Re: [net 00/13][pull request] Intel Wired LAN Driver Updates
Date: Sat, 12 Apr 2014 16:37:02 -0400 (EDT)
Message-ID: <20140412.163702.728558061125438607.davem@davemloft.net>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755580AbaDLUhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 16:37:07 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Apr 2014 06:52:50 -0700

> This series contains updates to e1000, e1000e, igb, igbvf, ixgb, ixgbe,
> ixgbevf and i40evf.
> 
> Mark fixes an issue with ixgbe and ixgbevf by adding a bit to indicate
> when workqueues have been initialized.  This permits the register read
> error handling from attempting to use them prior to that, which also
> generates warnings.  Checking for a detected removal after initializing
> the work queues allows the probe function to return an error without
> getting the workqueue involved.  Further, if the error_detected
> callback is entered before the workqueues are initialized, exit without
> recovery since the device initialization was so truncated.
> 
> Francois Romieu provides several patches to all the drivers to remove
> the open coded skb_cow_head.
> 
> Jakub Kicinski provides a fix for igb where last_rx_timestamp should be
> updated only when Rx time stamp is read.
> 
> Mitch provides a fix for i40evf where a recent change broke the RSS LUT
> programming causing it to be programmed with all 0's.

Pulled, thanks a lot Jeff.
