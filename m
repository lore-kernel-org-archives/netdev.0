From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next v2 0/2] net: stmmac: Improvements for
 multi-queuing and for AVB
Date: Fri, 13 Oct 2017 15:59:25 +0200
Message-ID: <c1e8e5ce-61dc-9e13-4d02-43e046d80620@st.com>
References: <cover.1507888312.git.joabreu@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Jose Abreu <Jose.Abreu@synopsys.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:2924 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753394AbdJMN7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:59:34 -0400
In-Reply-To: <cover.1507888312.git.joabreu@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes you need these settings, thx for these patches.

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

On 10/13/2017 11:58 AM, Jose Abreu wrote:
> Hi,
>
> Two improvements for stmmac: First one corrects the available fifo size per queue, second one corrects enabling of AVB queues. More info in commit log.
>
> Best regards,
> Jose Miguel Abreu
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Joao Pinto <jpinto@synopsys.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre Torgue <alexandre.torgue@st.com>
>
> Changes from v1:
> - Fix typo in second patch
>
> Jose Abreu (2):
>    net: stmmac: Use correct values in TQS/RQS fields
>    net: stmmac: Disable flow ctrl for RX AVB queues and really enable TX
>      AVB queues
>
>   drivers/net/ethernet/stmicro/stmmac/common.h      |  5 +--
>   drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  2 ++
>   drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 27 ++++++++++------
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 39 +++++++++++++++++++----
>   4 files changed, 56 insertions(+), 17 deletions(-)
>
