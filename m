From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH, net-next]r8169:Disable interrupts.
Date: Sat, 22 Aug 2015 13:23:02 +0200
Message-ID: <20150822112302.GA24519@electric-eye.fr.zoreil.com>
References: <1440219842-5462-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55298 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbbHVLXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 07:23:24 -0400
Content-Disposition: inline
In-Reply-To: <1440219842-5462-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
> Disable interrupts when close the interface.
> 
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 6cd7226..ea461fe 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7548,6 +7548,7 @@ static int rtl8169_close(struct net_device *dev)
>  
>  	/* Update counters before going down */
>  	rtl8169_update_counters(dev);
> +	rtl8169_irq_mask_and_ack(tp);

It's already called through
- rtl8169_close
  - rtl8169_down

-- 
Ueimor
