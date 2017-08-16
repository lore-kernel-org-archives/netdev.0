From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_router: Use correct config
 option
Date: Tue, 15 Aug 2017 17:05:23 -0700 (PDT)
Message-ID: <20170815.170523.1305734328748006612.davem@davemloft.net>
References: <20170815071033.1420-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43860 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752339AbdHPAFY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:05:24 -0400
In-Reply-To: <20170815071033.1420-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 15 Aug 2017 09:10:33 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> I made an embarrassing mistake and used 'IPV6' instead of 'CONFIG_IPV6'
> around the function that updates the kernel about IPv6 neighbours
> activity. This can be a problem if the kernel has more neighbours than a
> certain threshold and it starts deleting those that are supposedly
> inactive.
> 
> Fixes: b5f3e0d43012 ("mlxsw: spectrum_router: Fix build when IPv6 isn't enabled")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Also applied, thanks.
