From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 17/17] net: stmmac: replace unsigned by u32
Date: Tue, 31 Jan 2017 11:12:04 +0100
Message-ID: <95127c22-5cf3-9d19-97f7-519145e17654@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-18-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:24207 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751394AbdAaKOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:14:25 -0500
In-Reply-To: <20170131091152.13842-18-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> checkpatch complains about two unsigned without type after.
> Since the value return is u32, it is simpler to replace it by u32 instead
> of "unsigned int"
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>


Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index f0ce780..6260b6f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -187,7 +187,7 @@ static void print_pkt(unsigned char *buf, int len)
>
>  static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
>  {
> -	unsigned avail;
> +	u32 avail;
>
>  	if (priv->dirty_tx > priv->cur_tx)
>  		avail = priv->dirty_tx - priv->cur_tx - 1;
> @@ -199,7 +199,7 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
>
>  static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv)
>  {
> -	unsigned dirty;
> +	u32 dirty;
>
>  	if (priv->dirty_rx <= priv->cur_rx)
>  		dirty = priv->cur_rx - priv->dirty_rx;
>
