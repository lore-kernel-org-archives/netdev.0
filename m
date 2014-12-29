From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 2/6] cdc_ncm: be more precise in comments for cdc_ncm_prepare_skb_ncm16
Date: Mon, 29 Dec 2014 16:29:40 +0300
Message-ID: <54A15744.2050602@cogentembedded.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com> <1419847788-25610-3-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Enrico Mioso <mrkiko.rs@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:42034 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaL2N3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 08:29:40 -0500
Received: by mail-la0-f54.google.com with SMTP id pv20so10941098lab.41
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 05:29:39 -0800 (PST)
In-Reply-To: <1419847788-25610-3-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/29/2014 1:09 PM, Enrico Mioso wrote:

> The function might return NULL: callers must be prepared to this possibility.

> Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
> ---
>   drivers/net/usb/cdc_ncm.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 48fee7a..bcd9437 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -1015,7 +1015,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp16(struct cdc_ncm_ctx *ctx, struct s
>   }
>
>   /* Allocate new SKB for use with 16-bit NCM according to actual TX/RX
> -	settings */
> +	settings; returns NULL in case of errors */

    BTW, the preferred style for the multi-line comments in the networking 
code is:

/* bla
  * bla
  */

WBR, Sergei
