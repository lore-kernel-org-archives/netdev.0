From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/8] mlxsw: cleanup neigh handling
Date: Mon, 06 Feb 2017 11:28:44 -0500 (EST)
Message-ID: <20170206.112844.153468141426774611.davem@davemloft.net>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752155AbdBFQ2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:28:46 -0500
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  6 Feb 2017 16:20:09 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> This series addresses long standing issues in the mlxsw driver
> concerning neighbour reflection. It also prepares the code for follow-up
> changes dealing with proper resource cleanup and nexthop reflection.
> 
> The first two patches convert the neighbour reflection code to use an
> ordered workqueue, to prevent re-ordering of NEIGH_UPDATE events that
> may happen following subsequent patches.
> 
> The third to fifth patches remove the ndo_neigh_{construct,destroy}
> entry points from the driver, thereby relying only on NEIGH_UPDATE
> events for neighbour reflection. This simplifies the code considerably.
> 
> Last patches are fallout and adjust nits in the code I noticed while
> going over it.

Series applied, thanks.

Looks like 6lowpan is the only remaining user of the ndo_neigh_*() ops
now.
