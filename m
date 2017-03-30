From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: Re: [PATCH] [net-next] stmmac: use
 netif_set_real_num_{rx,tx}_queues
Date: Thu, 30 Mar 2017 18:35:44 +0200
Message-ID: <51947833-7559-0794-911d-d9cac65c5065@axis.com>
References: <20170328094856.3457886-1-arnd@arndb.de>
 <20170328.180105.1996071259325891752.davem@davemloft.net>
 <20170330074536.GA4814@Red> <20170330143435.GA28098@ulmo.ba.sec>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <arnd@arndb.de>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <Joao.Pinto@synopsys.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Thierry Reding <treding@nvidia.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:44846 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932749AbdC3Qft (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 12:35:49 -0400
In-Reply-To: <20170330143435.GA28098@ulmo.ba.sec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2017 04:34 PM, Thierry Reding wrote:
> On Thu, Mar 30, 2017 at 09:45:36AM +0200, Corentin Labbe wrote:
>> On Tue, Mar 28, 2017 at 06:01:05PM -0700, David Miller wrote:
>>> From: Arnd Bergmann <arnd@arndb.de>
>>> Date: Tue, 28 Mar 2017 11:48:21 +0200
>>>
>>>> A driver must not access the two fields directly but should instead use
>>>> the helper functions to set the values and keep a consistent internal
>>>> state:
>>>>
>>>> ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
>>>> ethernet/stmicro/stmmac/stmmac_main.c:4083:8: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
>>>>
>>>> Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configuration")
>>>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>>>
>>> Applied.
>>
>> This break my revert patch. (since it patch ("net: stmmac: enable multiple buffers").
>> Since dwmac-sunxi is still broken, what can I do ? send two revert patch ? or adapt the reverting patch.
> 
> Have you tried if the kcalloc() patch I sent on Tuesday fixes things the
> issues introduced by the multiple buffers patch? Niklas reported that it
> restores functionality on his setup.
> 
> If it makes things work for you as well, we could maybe avoid the revert
> altogether.

Thierry, I know that you are using DWMAC CORE 4.XX
How many RX queues and how many TX queues have you got?

I'm also using DWMAC CORE 4.XX
We have 2 TX queues and 1 RX queue.

I think that Corentin is using DWMAC CORE 3.XX

I know that Joao is using an IP Prototyping Kit that uses
DWMAC CORE 4.XX (connected via PCIe).
It would be nice if Joao could get an IP Prototyping Kit
based on DWMAC CORE 3.XX.

Doesn't Synopsys have an IP Prototyping Kit based on
DWMAC CORE 3.XX laying around somewhere? :)
