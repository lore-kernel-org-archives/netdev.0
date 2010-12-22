From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] bna: TxRx and datapath fix
Date: Wed, 22 Dec 2010 15:12:13 -0800 (PST)
Message-ID: <20101222.151213.115925760.davem@davemloft.net>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
	<1293002596-3239-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752100Ab0LVXLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 18:11:43 -0500
In-Reply-To: <1293002596-3239-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 21 Dec 2010 23:23:07 -0800

>  #define bnad_dim_timer_running(_bnad)				\
>  	(((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED) && 		\
>  	(test_bit(BNAD_RF_DIM_TIMER_RUNNING, &((_bnad)->run_flags))))
>  
> +#if defined(__ia64__)
> +#define bnad_udelay	udelay
> +#else
> +#define bnad_udelay	__udelay
> +#endif
> +

What in the world is this?

Something like this should absolutely, positively, never be necessary.

