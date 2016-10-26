From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH (net.git) 0/3] stmmac: fix PTP support
Date: Wed, 26 Oct 2016 09:29:56 +0200
Message-ID: <1cdc161b-a3e2-6656-bc05-77092db3cd26@st.com>
References: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <rayagond@vayavyalabs.com>, <richardcochran@gmail.com>,
        <linux-kernel@vger.kernel.org>, <seraphin.bonnaffe@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:15647 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753674AbcJZHaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 03:30:01 -0400
In-Reply-To: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,


On 10/26/2016 08:56 AM, Giuseppe Cavallaro wrote:
> This subset of patches aim to fix the PTP support
> for the stmmac and especially for 4.x chip series.
> While setting PTP on an ST box with 4.00a Ethernet
> core, the kernel panics due to a broken settings
> of the descriptors. The patches review the
> register configuration, the algo used for configuring
> the protocol, the way to get the timestamp inside
> the RX/TX descriptors and, in the end, the statistics
> displayed by ethtool.
>
> Giuseppe Cavallaro (3):
>   stmmac: update the PTP header file
>   stmmac: fix PTP support for GMAC4
>   stmmac: fix PTP type ethtool stats
>
>  drivers/net/ethernet/stmicro/stmmac/common.h       | 24 +++---
>  drivers/net/ethernet/stmicro/stmmac/descs.h        | 20 +++--
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 95 ++++++++++++++++-----
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h |  4 +
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c     | 28 ++++---
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  1 +
>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 19 +++--
>  .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  | 43 ++++++++--
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 97 +++++++++++-----------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  9 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   | 72 ++++++++--------
>  11 files changed, 260 insertions(+), 152 deletions(-)
>

For the series:
Acked-by: Alexandre Torgue <alexandre.torgue@st.com>

Thanks
Alex
