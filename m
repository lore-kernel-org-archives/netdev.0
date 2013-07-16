From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 2/6] bnx2x: prevent statistics update flow to act
 before statistics are started
Date: Tue, 16 Jul 2013 22:14:34 +0400
Message-ID: <51E58D8A.80206@cogentembedded.com>
References: <1373988107-305-1-git-send-email-dmitry@broadcom.com> <1373988107-305-3-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:63926 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933334Ab3GPSOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 14:14:33 -0400
Received: by mail-la0-f44.google.com with SMTP id er20so799574lab.3
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 11:14:32 -0700 (PDT)
In-Reply-To: <1373988107-305-3-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/16/2013 07:21 PM, Dmitry Kravkov wrote:

> This in order to serialize statistics requests sent to FW,
> otherwise two outstanding queries may cause FW assert.

> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       | 1 +
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 1 +
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 6 +++++-
>   3 files changed, 7 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index dedbd76..bdbd87e 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -1830,6 +1830,7 @@ struct bnx2x {
>
>   	int fp_array_size;
>   	u32 dump_preset_idx;
> +	atomic_t				stats_started;

    Why it's so wildly indented if its neighbors are not?

>   };
>
>   /* Tx queues may be less or equal to Rx queues */

WBR, Sergei
