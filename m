From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/4] mlxsw: Traps enhancements
Date: Mon, 17 Jul 2017 09:19:57 -0700 (PDT)
Message-ID: <20170717.091957.644800410884948370.davem@davemloft.net>
References: <20170717121532.4036-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbdGQQT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:19:58 -0400
In-Reply-To: <20170717121532.4036-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 17 Jul 2017 14:15:28 +0200

> Ido says:
> 
> The first patch makes sure the driver marks packets that were trapped
> in the router and might have already been flooded by the bridge, so that
> the bridge driver won't flood them again. This isn't critical at this time
> point, but will be when Neighbour Discovery traps are introduced as these
> are multicast packets that are trapped in the router.
> 
> The second and third patches add new traps - for MLD and Router Alert
> packets. The last patch takes advantage of that and floods IPv6
> unregistered multicast packets only to mrouter ports instead of all ports.

Series applied, thanks.
