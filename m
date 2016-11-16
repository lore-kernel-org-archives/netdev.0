From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix rtnl_vfinfo_size
Date: Tue, 15 Nov 2016 22:42:52 -0500 (EST)
Message-ID: <20161115.224252.570438889473921203.davem@davemloft.net>
References: <188991b3f1ede7ff1231f78411f4716cb5926950.1479202614.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, sucheta.chakraborty@qlogic.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752966AbcKPDmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:42:54 -0500
In-Reply-To: <188991b3f1ede7ff1231f78411f4716cb5926950.1479202614.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 15 Nov 2016 10:39:03 +0100

> The size reported by rtnl_vfinfo_size doesn't match the space used by
> rtnl_fill_vfinfo.
> 
> rtnl_vfinfo_size currently doesn't account for the nest attributes
> used by statistics (added in commit 3b766cd83232), nor for struct
> ifla_vf_tx_rate (since commit ed616689a3d9, which added ifla_vf_rate
> to the dump without removing ifla_vf_tx_rate, but replaced
> ifla_vf_tx_rate with ifla_vf_rate in the size computation).
> 
> Fixes: 3b766cd83232 ("net/core: Add reading VF statistics through the PF netdevice")
> Fixes: ed616689a3d9 ("net-next:v4: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable.
