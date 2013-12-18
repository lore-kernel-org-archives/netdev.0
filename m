From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qlcnic: make local functions static
Date: Wed, 18 Dec 2013 15:05:04 -0500 (EST)
Message-ID: <20131218.150504.682236658578560295.davem@davemloft.net>
References: <20131213123119.16358e1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com,
	netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab3LRUFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 15:05:08 -0500
In-Reply-To: <20131213123119.16358e1b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Fri, 13 Dec 2013 12:31:19 -0800

> Functions only used in one file should be static.
> Found by running make namespacecheck
> Remove function  qlcnic_enable_eswitch which was defined
> but never used in current code.
> 
> Compile tested only; do not have the hardware.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

You'll need to respin this as it doesn't apply to net-next at
the moment, thanks.
