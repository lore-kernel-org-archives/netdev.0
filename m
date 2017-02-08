From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/15] mlxsw: Reflect nexthop status changes
Date: Wed, 08 Feb 2017 15:28:48 -0500 (EST)
Message-ID: <20170208.152848.118275722298964427.davem@davemloft.net>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdBHVF5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 16:05:57 -0500
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  8 Feb 2017 11:16:27 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> When the kernel forwards IPv4 packets via multipath routes it doesn't
> consider nexthops that are dead or linkdown. For example, if the nexthop
> netdev is administratively down or doesn't have a carrier.
> 
> Devices capable of offloading such multipath routes need to be made
> aware of changes in the reflected nexthops' status. Otherwise, the
> device might forward packets via non-functional nexthops, resulting in
> packet loss. This patchset aims to fix that.
> 
> The first 11 patches deal with the necessary restructuring in the
> mlxsw driver, so that it's able to correctly add and remove nexthops
> from the device's adjacency table.
> 
> The 12th patch adds the NH_{ADD,DEL} events to the FIB notification
> chain. These notifications are sent whenever the kernel decides to add
> or remove a nexthop from the forwarding plane.
> 
> Finally, the last three patches add support for these events in the
> mlxsw driver, which is currently the only driver capable of offloading
> multipath routes.

Looks really nice, series applied, thanks!
