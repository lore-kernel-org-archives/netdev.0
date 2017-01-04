From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Enable Clause 45 PHYs in GAMC4
Date: Wed, 04 Jan 2017 14:11:41 -0500 (EST)
Message-ID: <20170104.141141.514392926320888488.davem@davemloft.net>
References: <14201d58c172f7a65b03510d36d55170f4d16cd5.1483540094.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hock.leong.kweh@intel.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750746AbdADTLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:11:43 -0500
In-Reply-To: <14201d58c172f7a65b03510d36d55170f4d16cd5.1483540094.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed,  4 Jan 2017 14:35:26 +0000

> The eQOS IP Core (best known in stmmac as gmac4) has a register that must be
> set if using a Clause 45 PHY. If this register is not set, the PHY won't work.
> This patch will have no impact in setups using Clause 22 PHYs.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Why don't you set this bit for MDIO reads as well?

If it isn't necessary for reads, you have to explain this in your commit
message otherwise people will wonder the same thing I did when they see
that only writes are handled.

Thanks.
