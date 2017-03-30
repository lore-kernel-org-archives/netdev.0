From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] stmmac: use
 netif_set_real_num_{rx,tx}_queues
Date: Thu, 30 Mar 2017 10:48:32 -0700 (PDT)
Message-ID: <20170330.104832.599422532945133952.davem@davemloft.net>
References: <20170328.180105.1996071259325891752.davem@davemloft.net>
        <20170330074536.GA4814@Red>
        <20170330143435.GA28098@ulmo.ba.sec>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clabbe.montjoie@gmail.com, arnd@arndb.de, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, Joao.Pinto@synopsys.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: treding@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933891AbdC3Rsh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 13:48:37 -0400
In-Reply-To: <20170330143435.GA28098@ulmo.ba.sec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <treding@nvidia.com>
Date: Thu, 30 Mar 2017 16:34:36 +0200

> On Thu, Mar 30, 2017 at 09:45:36AM +0200, Corentin Labbe wrote:
>> On Tue, Mar 28, 2017 at 06:01:05PM -0700, David Miller wrote:
>> > From: Arnd Bergmann <arnd@arndb.de>
>> > Date: Tue, 28 Mar 2017 11:48:21 +0200
>> > 
>> > > A driver must not access the two fields directly but should instead use
>> > > the helper functions to set the values and keep a consistent internal
>> > > state:
>> > > 
>> > > ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
>> > > ethernet/stmicro/stmmac/stmmac_main.c:4083:8: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
>> > > 
>> > > Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configuration")
>> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> > 
>> > Applied.
>> 
>> This break my revert patch. (since it patch ("net: stmmac: enable multiple buffers").
>> Since dwmac-sunxi is still broken, what can I do ? send two revert patch ? or adapt the reverting patch.
> 
> Have you tried if the kcalloc() patch I sent on Tuesday fixes things the
> issues introduced by the multiple buffers patch? Niklas reported that it
> restores functionality on his setup.

I think he said yesterday that he did indeed test all of your patches and it
did not fix things for him.

http://marc.info/?l=linux-kernel&m=149076922813085&w=2

I am going to revert the enable multiple buffers commit, and I would ask that
all involved parties work together in the background to resolve all of this.

Thank you.
