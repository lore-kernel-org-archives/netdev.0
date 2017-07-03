From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: correctly set vxlan->net when creating
 the device in a netns
Date: Mon, 03 Jul 2017 02:05:56 -0700 (PDT)
Message-ID: <20170703.020556.1659454918627153846.davem@davemloft.net>
References: <a21c497947fa98741df864ec4a855d121f8054cc.1498830270.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschiffer@universe-factory.net
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752501AbdGCJGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:06:00 -0400
In-Reply-To: <a21c497947fa98741df864ec4a855d121f8054cc.1498830270.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 30 Jun 2017 15:50:00 +0200

> Commit a985343ba906 ("vxlan: refactor verification and application of
> configuration") modified vxlan device creation, and replaced the
> assignment of vxlan->net to src_net with dev_net(netdev) in ->setup().
> 
> But dev_net(netdev) is not the same as src_net. At the time ->setup()
> is called, dev_net hasn't been set yet, so we end up creating the
> socket for the vxlan device in init_net.
> 
> Fix this by bringing back the assignment of vxlan->net during device
> creation.
> 
> Fixes: a985343ba906 ("vxlan: refactor verification and application of configuration")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.
