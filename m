From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: switchdev: fix return code of fdb_dump stub
Date: Mon, 16 Nov 2015 15:24:47 -0500 (EST)
Message-ID: <20151116.152447.696343346331416928.davem@davemloft.net>
References: <5649A770.8090909@endocode.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sridhar.samudrala@intel.com,
	jiri@mellanox.com
To: dragos@endocode.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbbKPUYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:24:49 -0500
In-Reply-To: <5649A770.8090909@endocode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dragos Tatulea <dragos@endocode.com>
Date: Mon, 16 Nov 2015 10:52:48 +0100

> rtnl_fdb_dump always expects an index to be returned by the ndo_fdb_dump op,
> but when CONFIG_NET_SWITCHDEV is off, it returns an error.
> 
> Fix that by returning the given unmodified idx.
> 
> A similar fix was 0890cf6cb6ab ("switchdev: fix return value of
> switchdev_port_fdb_dump in case of error") but for the CONFIG_NET_SWITCHDEV=y
> case.
> 
> Fixes: 45d4122ca7cd ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.")
> Signed-off-by: Dragos Tatulea <dragos@endocode.com>

Applied, thanks.
