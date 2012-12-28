From: Tushar Behera <tushar.behera@linaro.org>
Subject: Re: [PATCH 10/14] atm: Removed redundant check on unsigned variable
Date: Fri, 28 Dec 2012 10:46:36 +0530
Message-ID: <50DD2B34.9070905@linaro.org>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org> <1353048646-10935-11-git-send-email-tushar.behera@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: patches@linaro.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:57087 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab2L1FRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 00:17:00 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so4611069dam.18
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 21:16:59 -0800 (PST)
In-Reply-To: <1353048646-10935-11-git-send-email-tushar.behera@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping.

On 11/16/2012 12:20 PM, Tushar Behera wrote:
> No need to check whether unsigned variable is less than 0.
> 
> CC: Chas Williams <chas@cmf.nrl.navy.mil>
> CC: linux-atm-general@lists.sourceforge.net
> CC: netdev@vger.kernel.org
> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
> ---
>  drivers/atm/fore200e.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
> index 361f5ae..fdd3fe7 100644
> --- a/drivers/atm/fore200e.c
> +++ b/drivers/atm/fore200e.c
> @@ -972,7 +972,7 @@ int bsq_audit(int where, struct host_bsq* bsq, int scheme, int magn)
>  		   where, scheme, magn, buffer->index, buffer->scheme);
>  	}
>  
> -	if ((buffer->index < 0) || (buffer->index >= fore200e_rx_buf_nbr[ scheme ][ magn ])) {
> +	if (buffer->index >= fore200e_rx_buf_nbr[ scheme ][ magn ]) {
>  	    printk(FORE200E "bsq_audit(%d): queue %d.%d, out of range buffer index = %ld !\n",
>  		   where, scheme, magn, buffer->index);
>  	}
> 


-- 
Tushar Behera
