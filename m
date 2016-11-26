From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/19] mlxsw: traps, trap groups and policers
Date: Fri, 25 Nov 2016 21:22:53 -0500 (EST)
Message-ID: <20161125.212253.1659605651075984675.davem@davemloft.net>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752810AbcKZCXA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 21:23:00 -0500
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 25 Nov 2016 10:33:28 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Nogah says:
> 
> For a packet to be sent from the HW to the cpu, it needs to be trapped.
> For a trap to be activate it should be assigned to a trap group.
> Those trap groups can have policers, to limit the packet rate (the max
> number of packets that can be sent to the cpu in a time slot, the rest
> will be discarded) or the data rate (the same, but the count is not by the
> number of packets but by their total length in bytes).
> 
> This patchset rearrange the trap setting API, re-write the traps and the
> trap groups list in spectrum and assign them policers.

Series applied, thanks.
