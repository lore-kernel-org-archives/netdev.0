From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: simplify padding and length checks
Date: Thu, 21 Jun 2012 13:38:07 -0700 (PDT)
Message-ID: <20120621.133807.59441426155221033.davem@davemloft.net>
References: <1340280910-22651-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760191Ab2FUUiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 16:38:08 -0400
In-Reply-To: <1340280910-22651-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 21 Jun 2012 05:15:10 -0700

> From: Stephen Hemminger <shemminger@vyatta.com>
> 
> The check for length <= 0 is bogus because length is unsigned, and network
> stack never sends zero length packets (unless it is totally broken).
> 
> The check for really small packets can be optimized (using unlikely)
> and calling skb_pad directly.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Not really fixing anything and more of a cleanup, so maybe 'net-next'
instead of 'net' for this guy instead?
