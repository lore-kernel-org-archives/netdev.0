From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH (net.git) 1/6] stmmac: disable at run-time the EEE if
 not supported
Date: Tue, 25 Feb 2014 20:29:24 +0400
Message-ID: <530CC4E4.40301@cogentembedded.com>
References: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:35469 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbaBYQ3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 11:29:30 -0500
Received: by mail-la0-f45.google.com with SMTP id hr17so1446250lab.32
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 08:29:29 -0800 (PST)
In-Reply-To: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-02-2014 13:58, Giuseppe Cavallaro wrote:

> This patch is to disable the EEE (so HW and timers)
> for example when the phy communicates that the EEE
> can be supported anymore.

> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   24 ++++++++++++++++----
>   1 files changed, 19 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 078ad0e..dc89dc3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
[...]
> @@ -2204,7 +2219,6 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>   static void stmmac_tx_timeout(struct net_device *dev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(dev);
> -

    Why? Empty line is needed here, after declaration.

>   	/* Clear Tx resources and restart transmitting again */
>   	stmmac_tx_err(priv);
>   }

WBR, Sergei
