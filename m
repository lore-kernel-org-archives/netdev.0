From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH (net.git) 1/2] stmmac: disable at run-time the EEE if
 not supported
Date: Mon, 19 Aug 2013 22:44:24 +0400
Message-ID: <52126788.4060607@cogentembedded.com>
References: <1376894288-31279-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:39656 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3HSSoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:44:24 -0400
Received: by mail-lb0-f178.google.com with SMTP id z5so3308754lbh.37
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 11:44:22 -0700 (PDT)
In-Reply-To: <1376894288-31279-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/19/2013 10:38 AM, Giuseppe CAVALLARO wrote:

> This patch is to disable the EEE (so HW and timers)
> for example when the phy communicates that the EEE
> can be supported nomore.

> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   24 ++++++++++++++++----
>   1 files changed, 19 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 0a9bb9d..75cc2d3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
[...]
> @@ -2166,7 +2181,6 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>   static void stmmac_tx_timeout(struct net_device *dev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(dev);
> -
>   	/* Clear Tx resources and restart transmitting again */

    Why? This seems unneeded change.

WBR, Sergei
