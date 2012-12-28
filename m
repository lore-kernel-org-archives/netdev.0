From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: respect RFC2863 operational state
Date: Fri, 28 Dec 2012 15:27:54 -0800 (PST)
Message-ID: <20121228.152754.707370216340290808.davem@davemloft.net>
References: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171Ab2L1X2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 18:28:02 -0500
In-Reply-To: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 27 Dec 2012 22:28:54 -0800

>  	spin_lock_bh(&br->lock);
> -	if (netif_running(dev) && netif_carrier_ok(dev)) {
> +	if (netif_running(dev) && netif_oper_up(dev))
>  		if (p->state == BR_STATE_DISABLED)
>  			br_stp_enable_port(p);
>  	} else {

You didn't even try to compile this.
