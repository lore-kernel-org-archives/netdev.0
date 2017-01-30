From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 5/8] net/mlx4_en: Adding support of turning
 off link autonegotiation via ethtool
Date: Mon, 30 Jan 2017 15:25:32 -0500 (EST)
Message-ID: <20170130.152532.370636093483999005.davem@davemloft.net>
References: <1485708980-23468-1-git-send-email-tariqt@mellanox.com>
        <1485708980-23468-6-git-send-email-tariqt@mellanox.com>
        <063D6719AE5E284EB5DD2968C1650D6DB0273B7E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tariqt@mellanox.com, netdev@vger.kernel.org, eranbe@mellanox.com,
        lariel@mellanox.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754460AbdA3U0F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:26:05 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0273B7E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 30 Jan 2017 14:00:28 +0000

> From: Tariq Toukan
>> Sent: 29 January 2017 16:56
>> From: Ariel Levkovich <lariel@mellanox.com>
>> 
>> This feature will allow the user to disable auto negotiation
>> on the port for mlx4 devices while setting the speed is limited
>> to 1GbE speeds.
>> Other speeds will not be accepted in autoneg off mode.
> 
> What is the rationale behind this change?

Because it's an ethtool user feature we've had to two decades
and it allows the user greater control over the link state.

> When I was writing ethernet drivers it was always better to
> leave autonegotiation enabled with restricted modes than to
> fix the speed.

Nothing about this change effects this.  The user is just given
the ability to turn autonegotiation off if they wish to do so.
