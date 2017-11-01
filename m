From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: reg: Add high and low temperature thresholds
Date: Wed, 01 Nov 2017 12:26:08 +0900 (KST)
Message-ID: <20171101.122608.426616948272437926.davem@davemloft.net>
References: <20171030095118.9098-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44892 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdKAD0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:26:11 -0400
In-Reply-To: <20171030095118.9098-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 30 Oct 2017 10:51:18 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> The ASIC has the ability to generate events whenever a sensor indicates
> the temperature goes above or below its high or low thresholds,
> respectively.
> 
> In new firmware versions the firmware enforces a minimum of 5
> degrees Celsius difference between both thresholds. Make the driver
> conform to this requirement.
> 
> Note that this is required even when the events are disabled, as in
> certain systems interrupts are generated via GPIO based on these
> thresholds.
> 
> Fixes: 85926f877040 ("mlxsw: reg: Add definition of temperature management registers")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
