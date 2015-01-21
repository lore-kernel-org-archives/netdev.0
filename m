From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: stmmac: add BQL support
Date: Wed, 21 Jan 2015 10:37:03 -0800
Message-ID: <1421865423.4832.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421863647-20048-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Beniamino Galvani <b.galvani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:56707 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbAUShQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 13:37:16 -0500
In-Reply-To: <1421863647-20048-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-21 at 19:07 +0100, Beniamino Galvani wrote:
> Add support for Byte Queue Limits to the STMicro MAC driver.
> 
> Tested on a Amlogic S802 quad Cortex-A9 board, where the use of BQL
> decreases the latency of a high priority ping from ~12ms to ~1ms when
> the 100Mbit link is saturated by 20 TCP streams.
> 
> Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
> ---
> Changes since v1:
>  - don't access skb->len after the start of DMA transmission in
>    stmmac_xmit(), to avoid potential use after free in case tx_lock is
>    removed in the future
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 9 +++++++++
>  1 file changed, 9 insertions(+)

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
