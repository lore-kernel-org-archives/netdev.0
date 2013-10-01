From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Tue, 01 Oct 2013 12:51:16 -0400 (EDT)
Message-ID: <20131001.125116.1237920409152830224.davem@davemloft.net>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab3JAQvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:51:18 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  1 Oct 2013 04:33:47 -0700

> This series contains updates to ixgbevf, ixgbe and igb.
> 
> Don provides 3 patches for ixgbevf where he cleans up a redundant
> read mailbox failure check, adds a new function to wait for receive
> queues to be disabled before disabling NAPI, and move the API
> negotiation so that it occurs in the reset path.  This will allow
> the PF to be informed of the API version earlier.
> 
> Jacob provides a ixgbevf and ixgbe patch.  His ixgbevf patch removes
> the use of hw_dbg when the ixgbe_get_regs function is called in ethtool.
> The ixgbe patch renames the LL_EXTENDED_STATS and some of the functions
> required to implement busy polling in order to remove the marketing
> "low latency" blurb which hides what the code actually does.
> 
> Leonardo provides a ixgbe patch to add support for DCB registers dump
> using ethtool for 82599 and x540 ethernet controllers.
> 
> I (Jeff) provide a ixgbe patch to cleanup whitespace issues seen in a
> code review.
> 
> Todd provides for igb to add support for i354 in the ethtool offline
> tests.
> 
> Laura provides an igb patch to add the ethtool callbacks necessary to
> configure the number of RSS queues.

Pulled, thanks Jeff.

Please address Ben Hutching's concerns about the state of the device
after a number of channels configuration failure with follow-on
changes, if necessary.

Thanks.
