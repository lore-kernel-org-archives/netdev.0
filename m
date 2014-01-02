From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/5] alx: add stats update function
Date: Wed, 1 Jan 2014 21:55:09 -0800
Message-ID: <20140101215509.4a9f139c@nehalam.linuxnetplumber.net>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	<1388619628-3373-4-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:59882 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaABFzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 00:55:15 -0500
Received: by mail-pd0-f170.google.com with SMTP id g10so13838145pdj.29
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 21:55:15 -0800 (PST)
In-Reply-To: <1388619628-3373-4-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  2 Jan 2014 00:40:26 +0100
Sabrina Dubroca <sd@queasysnail.net> wrote:

> diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
> index 207bcc6..97e8731 100644
> --- a/drivers/net/ethernet/atheros/alx/hw.h
> +++ b/drivers/net/ethernet/atheros/alx/hw.h
> @@ -482,6 +482,8 @@ struct alx_hw {
>  
>  	/* PHY link patch flag */
>  	bool lnk_patch;
> +
> +	struct alx_hw_stats stats;
>  };

Why do you need this to be part of the hw struct?
It doesn't need to be persistent.
couldn't the callers just pass it on the stack.
