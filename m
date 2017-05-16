From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipmr: vrf: Find VIFs using the actual device
Date: Tue, 16 May 2017 12:52:31 -0400 (EDT)
Message-ID: <20170516.125231.1501295303351652146.davem@davemloft.net>
References: <20170515221444.4913-1-Thomas.Winter@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, roopa@cumulusnetworks.com
To: Thomas.Winter@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753232AbdEPQwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:52:33 -0400
In-Reply-To: <20170515221444.4913-1-Thomas.Winter@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>
Date: Tue, 16 May 2017 10:14:44 +1200

> The skb->dev that is passed into ip_mr_input is
> the loX device for VRFs. When we lookup a vif
> for this dev, none is found as we do not create
> vifs for loopbacks. Instead lookup a vif for the
> actual device that the packet was received on,
> eg the vlan.
> 
> Signed-off-by: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>

Applied, thank you.
