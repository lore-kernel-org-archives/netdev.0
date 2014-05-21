From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net/mlx4_core: Deprecate use_prio module
 parameter
Date: Wed, 21 May 2014 15:49:52 -0400 (EDT)
Message-ID: <20140521.154952.422112298525039373.davem@davemloft.net>
References: <1400488662-5657-1-git-send-email-amirv@mellanox.com>
	<1400488662-5657-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, clsoto@linux.vnet.ibm.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbaEUTty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 15:49:54 -0400
In-Reply-To: <1400488662-5657-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 19 May 2014 11:37:41 +0300

> It was used for steering by user priority for A0 steering. A0 mode is
> not supported anymore. Printing a message and ignoring the parameter.
> 
> CC: Carol Soto <clsoto@linux.vnet.ibm.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

So you completely took away a feature that was publicly exposed and
available to the user?

Sorry this is still not acceptable, you have to bring back A0
steering, what if someone was using it?

I sense you really don't care, and that I find really disturbing.
