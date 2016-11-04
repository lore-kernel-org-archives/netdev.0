From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 0/3] stmmac: fix PTP support
Date: Fri, 4 Nov 2016 14:53:09 +0100
Message-ID: <f215077e-e37d-b59d-763b-370ecc06792e@st.com>
References: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexandre.torgue@st.com>, <rayagond@vayavyalabs.com>,
        <richardcochran@gmail.com>, <linux-kernel@vger.kernel.org>,
        <seraphin.bonnaffe@st.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

the series have some Acked-by, do you prefer a new
series (I can rebase them if you ask me) or you can keep
this one? Or you have some advice or issue to warn?

Regards,
peppe

On 10/26/2016 8:56 AM, Giuseppe Cavallaro wrote:
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
