From: David Miller <davem@davemloft.net>
Subject: Re: Should we report bus width/speed via ethtool?
Date: Wed, 05 Dec 2012 17:36:50 -0500 (EST)
Message-ID: <20121205.173650.1310171220758794440.davem@davemloft.net>
References: <50BFBE05.7020408@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab2LEWgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 17:36:55 -0500
In-Reply-To: <50BFBE05.7020408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 05 Dec 2012 13:35:01 -0800

> It seems the only way to get the current pci-e bus speed & width
> in ixgbe (and probably many other NICs) is by parsing output
> of lspci -vvv.
> 
> I'd personally find it easier if this info were available via
> ethtool API.

You could just as easily have ethtool determine the PCI device
location (using existing facilities) and fetch the PCI-e info from the
PCI sysfs files.

There is no reason to extend ethtool for this.
