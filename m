From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/7][pull request] Intel Wired LAN Driver Updates
Date: Mon, 21 Apr 2014 12:58:58 -0400 (EDT)
Message-ID: <20140421.125858.1669714683420708606.davem@davemloft.net>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaDUQ7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 12:59:04 -0400
In-Reply-To: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Apr 2014 18:59:20 -0700

> This series contains updates to e1000e, igb, ixgbe and i40e.
> 
> Most notably are Jakub's patches to clean up the Rx time stamping
> code for ixgbe and the fix up of debug messages with proper termination.
> 
> Jesse's i40e patch fixes an issue reported by Eric Dumazet that the
> i40e driver was allowing the hardware to replicate the PSH flag on
> all segments of a TSO operation.  With this fix, we are now configuring
> the CWR bit to only be set in the first packet of a TSO and we
> enable TSO_ECN in order to advertise to the stack that we do the right
> thing on the wire.
> 
> The following are changes since commit b14878ccb7fac0242db82720b784ab62c467c0dc:
>   net: sctp: cache auth_enable per endpoint
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks Jeff.
