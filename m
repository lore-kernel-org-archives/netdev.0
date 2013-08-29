From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/10][pull request] Intel Wired LAN Driver
 Updates
Date: Thu, 29 Aug 2013 16:14:15 -0400 (EDT)
Message-ID: <20130829.161415.1218612845288168089.davem@davemloft.net>
References: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab3H2UOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:14:18 -0400
In-Reply-To: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 29 Aug 2013 03:49:56 -0700

> This series contains updates to ixgbe.
> 
> Jacob provides a fix for 82599 devices where it can potentially keep link
> lights up when the adapter has gone down.
> 
> Mark provides a fix to resolve the possible use of uninitialized memory
> by checking the return value on EEPROM reads.
> 
> Don provides 2 patches, one to fix a issue where we were traversing the
> Tx ring with the value of IXGBE_NUM_RX_QUEUES which currently happens
> to have the correct value but this is misleading.  A change later, could
> easily make this no longer correct so when traversing the Tx ring, use
> netdev->num_tx_queues.  His second patch does some minor clean ups of log
> messages.
> 
> Emil provides the remaining ixgbe patches.  First he fixes the link test
> where forcing the laser before the link check can lead to inconsistent
> results because it does not guarantee that the link will be negotiated
> correctly.  Then he initializes the message buffer array to 0 in order
> to avoid using random numbers from the memory as a MAC address for the
> VF.  Emil also fixes the read loop for the I2C data to account for the
> offset for SFP+ modules.  Lastly, Emil provides several patches to add
> support for QSFP modules where 1Gbps support is added as well as support
> for older QSFP active direct attach cables which pre-date SFF-8436 v3.6.
> 
> v2: Fixed patch 4 description and added blank line based on feedback from
>     Sergei Shtylyov

Pulled, thanks Jeff.
