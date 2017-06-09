From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/6] netvsc: use typed pointer for internal state
Date: Fri, 9 Jun 2017 13:24:24 +0300
Message-ID: <a26be48a-b3c8-484c-5415-f13aeee34d02@cogentembedded.com>
References: <20170608232123.28366-1-sthemmin@microsoft.com>
 <20170608232123.28366-4-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>, kys@microsoft.com,
        haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34887 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751519AbdFIKY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 06:24:28 -0400
Received: by mail-lf0-f49.google.com with SMTP id p189so28032572lfe.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 03:24:27 -0700 (PDT)
In-Reply-To: <20170608232123.28366-4-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/9/2017 2:21 AM, Stephen Hemminger wrote:

> The element netvsc_device:extension is always a point to RNDIS

    Pointer, maybe?

> information.
>
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  drivers/net/hyperv/hyperv_net.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index 262b2ea576a3..f82d54e0208c 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -763,8 +763,7 @@ struct netvsc_device {
>
>  	refcount_t sc_offered;
>
> -	/* Holds rndis device info */
> -	void *extension;
> +	struct rndis_device *extension;
>
>  	int ring_size;
>

MBR, Sergei
