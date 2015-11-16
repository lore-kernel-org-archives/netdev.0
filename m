From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] switchdev: bridge: Check return code is not
 EOPNOTSUPP
Date: Mon, 16 Nov 2015 14:56:27 -0500 (EST)
Message-ID: <20151116.145627.1996085836389504022.davem@davemloft.net>
References: <1447412772-29745-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	eladr@mellanox.com, linux@eikelenboom.it, jiri@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbbKPT43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:56:29 -0500
In-Reply-To: <1447412772-29745-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Fri, 13 Nov 2015 13:06:12 +0200

> When NET_SWITCHDEV=n, switchdev_port_attr_set simply returns EOPNOTSUPP.
> In this case we should not emit errors and warnings to the kernel log.
> 
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Fixes: 0bc05d585d38 ("switchdev: allow caller to explicitly request
> attr_set as deferred")
> Fixes: 6ac311ae8bfb ("Adding switchdev ageing notification on port
> bridged")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
