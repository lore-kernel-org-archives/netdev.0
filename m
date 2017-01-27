From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 1/2] net/ipv6: allow sysctl to change
 link-local address generation mode
Date: Fri, 27 Jan 2017 10:25:47 -0500 (EST)
Message-ID: <20170127.102547.1726260389181086804.davem@davemloft.net>
References: <20170126035918.7332-1-felix.jia@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org
To: felix.jia@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932227AbdA0P0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:26:24 -0500
In-Reply-To: <20170126035918.7332-1-felix.jia@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Jia <felix.jia@alliedtelesis.co.nz>
Date: Thu, 26 Jan 2017 16:59:17 +1300

> The address generation mode for IPv6 link-local can only be configured
> by netlink messages. This patch adds the ability to change the address
> generation mode via sysctl.
> 
> v1 -> v2
> Removed the rtnl lock and switch to use RCU lock to iterate through
> the netdev list.
> 
> v2 -> v3
> Removed the addrgenmode variable from the idev structure and use the 
> systcl storage for the flag.
> 
> Simplifed the logic for sysctl handling by removing the supported 
> for all operation.
> 
> Added support for more types of tunnel interfaces for link-local 
> address generation.
> 
> Based the patches from net-next.
> 
> v3 -> v4
> Removed unnecessary whitespace changes.
> 
> Signed-off-by: Felix Jia <felix.jia@alliedtelesis.co.nz>

Applied.
