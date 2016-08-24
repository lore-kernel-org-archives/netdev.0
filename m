From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/7] mlxsw: Offload FDB learning configuration
Date: Wed, 24 Aug 2016 09:41:30 -0700 (PDT)
Message-ID: <20160824.094130.639133337347281844.davem@davemloft.net>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33633 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756224AbcHXQlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:41:50 -0400
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 24 Aug 2016 12:00:22 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> This patchset addresses two long standing issues in the mlxsw driver
> concerning FDB learning.
> 
> Patch 1 limits the number of FDB records processed by the driver in a
> single session. This is useful in situations in which many new records
> need to be processed, thereby causing the RTNL mutex to be held for
> long periods of time.
> 
> Patches 2-6 offload the learning configuration (on / off) of bridge
> ports to the device instead of having the driver decide whether a
> record needs to be learned or not.
> 
> The last patch is fallout and removes configuration no longer necessary
> after the first patches are applied.

Looks good, series applied, thanks!
