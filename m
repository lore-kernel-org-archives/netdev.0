From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Pass VLAN ID to rtnl_fdb_notify.
Date: Thu, 09 Apr 2015 17:31:19 -0400 (EDT)
Message-ID: <20150409.173119.2113737976874415284.davem@davemloft.net>
References: <C039B2B452EFF24BA495644ED97341911BD52B94@IRSMSX107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marco.varlese@intel.com
To: hubert.sokolowski@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbDIVbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 17:31:21 -0400
In-Reply-To: <C039B2B452EFF24BA495644ED97341911BD52B94@IRSMSX107.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sokolowski, Hubert" <hubert.sokolowski@intel.com>
Date: Thu, 9 Apr 2015 12:16:17 +0000

> When an FDB entry is added or deleted the information about VLAN
> is not passed to listening applications like 'bridge monitor fdb'.
> With this patch VLAN ID is passed if it was set in the original
> netlink message.
> 
> Also remove an unused bdev variable.
> 
> Signed-off-by: Hubert Sokolowski <hubert.sokolowski@intel.com>

Ok, applied, thanks.
