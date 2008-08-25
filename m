From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp header size miscalculation when window
 scale is unused
Date: Mon, 25 Aug 2008 14:07:52 -0700 (PDT)
Message-ID: <20080825.140752.41921187.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069081@europa>
	<20080824.174544.244704849.davem@davemloft.net>
	<48B2DE15.70708@emc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: love_phil@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49336
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753335AbYHYVH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 17:07:56 -0400
In-Reply-To: <48B2DE15.70708@emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Love <love_phil@emc.com>
Date: Mon, 25 Aug 2008 09:30:13 -0700

> Here is the patch using Thunderbird, rather than Apple Mail. Hopefully 
> it is not mangled this time.
> 
> Signed-off-by: Philip Love <love_phil@emc.com>

Unfortunately it is still mangled.

> --- a/net/ipv4/tcp_output.c	2008-08-24 07:44:18.000000000 -0700
> +++ b/net/ipv4/tcp_output.c	2008-08-24 07:43:05.000000000 -0700
> @@ -468,7 +468,8 @@ static unsigned tcp_syn_options(struct s
>   	}
>   	if (likely(sysctl_tcp_window_scaling)) {
>   		opts->ws = tp->rx_opt.rcv_wscale;
> -		size += TCPOLEN_WSCALE_ALIGNED;
> +		if(likely(opts->ws))
> +			size += TCPOLEN_WSCALE_ALIGNED;
>   	}
>   	if (likely(sysctl_tcp_sack)) {
>   		opts->options |= OPTION_SACK_ADVERTISE;

On those lines of the patch where no changes are occuring there
should be a single space then one or more tab characters.

There are instead two spaces then the tab characters.
