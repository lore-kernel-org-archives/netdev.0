From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/10][pull request] Intel Wired LAN Driver
 Updates
Date: Thu, 13 Mar 2014 15:04:03 -0400 (EDT)
Message-ID: <20140313.150403.1216425576381362401.davem@davemloft.net>
References: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbaCMTEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:04:05 -0400
In-Reply-To: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 12 Mar 2014 19:31:20 -0700

> This series contains updates to igb, e1000e, ixgbe and ixgbevf.
> 
> Tom Herbert provides changes to e1000e, igb and ixgbe to call skb_set_hash()
> to set the hash and its type in an skbuff.
> 
> Carolyn provides a fix for igb where using ethtool for EEE settings, which
> was not working correctly.
> 
> Jacob provides some trivial cleanups and fixes for ixgbe which mainly
> dealt with the file headers.
> 
> Julia Lawall provides a one fix for ixgbevf where the driver did not need
> to adjust the power state on suspend, so the call to pci_set_power_state()
> in the resume function was a no-op.
> 
> v2:
> - dropped patches 4-6 from original series which implemented debugfs for
>   igb from Carolyn based on feed back from David Miller and Or Gerlitz

Pulled, thanks a lot Jeff.

BTW, from patch #3:

+	/*Re-establish EEE setting */

There really should be a space after "/*", please fix this up in a future
pull request.

Thanks.
