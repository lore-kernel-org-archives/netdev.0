From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 00/17] net: stmmac: misc fix
Date: Tue, 31 Jan 2017 11:00:08 +0100
Message-ID: <c04f9218-0661-7cb6-c18f-46fd420c6e28@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:36409 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750897AbdAaKAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:00:19 -0500
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Corentin

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> Hello
>
> I am currently working on dwmac-sun8i glue driver for Allwinner H3/A83T/A64.
> This serie is the result of all minor problem found in the stmmac driver.

thank for this effort, many changes are to tidy up some part of the code
so  I wonder if these should stay on top of net-next.
There is on-going a thread to change something in the stmmac (where I
missed more details and I tried to refresh all asap); so added on copy
Joao.

I will give you my feedback on some patches too.

peppe

> Regards
>
> Corentin Labbe (17):
>   net: stmmac: fix the typo on MAC_RNABLE_RX
>   net: stmmac: Remove the bus_setup function pointer
>   net: stmmac: fix some typos in comments
>   net: stmmac: remove freesoftware address
>   net: stmmac: remplace asm/io.h by linux/io.h
>   net: stmmac: fix some code style problem
>   net: stmmac: replace stmmac_mdio_busy_wait by readl_poll_timeout
>   net: stmmac: Use readl_poll_timeout
>   net: stmmac: replace ENOSYS by EINVAL
>   net: stmmac: Correct the error message about invalid speed
>   net: stmmac: Rewrite two test against NULL value
>   net: stmmac: rename rx_crc to rx_crc_errors
>   net: stmmac: Implement NAPI for TX
>   net: stmmac: print phy information
>   net: stmmac: remove dead code in stmmac_tx_clean
>   net: stmmac: remove unused variable in sysfs_display_ring
>   net: stmmac: replace unsigned by u32
>
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |  4 --
>  drivers/net/ethernet/stmicro/stmmac/common.h       |  8 +--
>  drivers/net/ethernet/stmicro/stmmac/descs.h        |  4 --
>  drivers/net/ethernet/stmicro/stmmac/descs_com.h    |  4 --
>  drivers/net/ethernet/stmicro/stmmac/dwmac100.h     |  4 --
>  drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |  4 --
>  .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  4 --
>  .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |  4 --
>  .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  4 --
>  drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  4 --
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c |  2 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |  4 --
>  drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    | 28 ++++------
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |  6 +--
>  drivers/net/ethernet/stmicro/stmmac/mmc.h          |  4 --
>  drivers/net/ethernet/stmicro/stmmac/mmc_core.c     |  4 --
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |  6 +--
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |  4 --
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  4 --
>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  6 +--
>  .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  4 --
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 63 ++++++++++------------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 52 +++++++-----------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  4 --
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  6 +--
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  4 --
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |  4 --
>  include/linux/stmmac.h                             |  1 -
>  28 files changed, 65 insertions(+), 185 deletions(-)
>
