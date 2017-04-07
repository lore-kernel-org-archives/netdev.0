From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 02/12] ftgmac100: Move ftgmac100_hard_start_xmit() around
Date: Fri, 7 Apr 2017 13:09:22 +0300
Message-ID: <10736779-3bcf-e797-cfaa-bdcc12b9d5f4@cogentembedded.com>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
 <20170407033105.29558-3-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36672 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753282AbdDGKJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 06:09:25 -0400
Received: by mail-lf0-f51.google.com with SMTP id s141so4058282lfe.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 03:09:25 -0700 (PDT)
In-Reply-To: <20170407033105.29558-3-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 4/7/2017 6:30 AM, Benjamin Herrenschmidt wrote:

> Move it below ftgmac100_xmit() and the rest of the tx path
>
> No code change.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 59 ++++++++++++++++----------------
>  1 file changed, 30 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index f4b719214..3966c7a 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -63,6 +63,7 @@ struct ftgmac100 {
>  	u32 rxdes0_edorr_mask;
>
>  	/* Tx ring */
> +	struct sk_buff *tx_skbs[TX_QUEUE_ENTRIES];

    "No code change", really?

>  	unsigned int tx_clean_pointer;
>  	unsigned int tx_pointer;
>  	unsigned int tx_pending;
[...]

MBR, Sergei
