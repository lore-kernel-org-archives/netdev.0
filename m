From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] switchdev: respect SKIP_EOPNOTSUPP flag in
 case there is no recursion
Date: Tue, 03 Nov 2015 13:37:53 -0500 (EST)
Message-ID: <20151103.133753.1743961419370989382.davem@davemloft.net>
References: <1446568853-8705-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778AbbKCSh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:37:56 -0500
In-Reply-To: <1446568853-8705-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  3 Nov 2015 17:40:53 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Caller passing down the SKIP_EOPNOTSUPP switchdev flag expects that
> -EOPNOTSUPP cannot be returned. But in case of direct op call without
> recurtion, this may happen. So fix this by checking it always on the
> end of __switchdev_port_attr_set function.
> 
> Fixes: 464314ea6c11 ("switchdev: skip over ports returning -EOPNOTSUPP when recursing ports")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
