From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next] stmmac: call stmmac_init_phy from
 stmmac_dvr_probe
Date: Mon, 20 Mar 2017 17:42:25 +0000
Message-ID: <ca027cda-2a8f-55d9-42e9-7f26e832e7bf@synopsys.com>
References: <20170320172915.8313-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Niklas Cassel <niklass@axis.com>
To: Niklas Cassel <niklas.cassel@axis.com>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:57179 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753264AbdCTRmb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 13:42:31 -0400
In-Reply-To: <20170320172915.8313-1-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 5:29 PM de 3/20/2017, Niklas Cassel escreveu:
> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> It is usually possible to do
> ethtool -s autoneg on
> so that you trigger an autoneg before calling
> ip link set dev eth0 up
> 
> However, stmmac returns -EBUSY if !netif_running.
> The only reason for this appears to be that stmmac_init_phy
> is called from stmmac_open instead of from stmmac_dvr_probe.
> 
> Move stmmac_init_phy to stmmac_dvr_probe so that ethool
> works as soon as register_netdev has been called.
> stmmac_check_ether_addr was also moved to probe,
> so that the ordering doesn't change.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> ---

Hi Niklas, did you test this patch?

Thanks.
Joao
