From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net 2/8] sfc: PTP: Moderate log message on event queue
 overflow
Date: Tue, 10 Dec 2013 18:15:53 -0800
Message-ID: <1386728153.8168.27.camel@joe-AO722>
References: <1386726826.1516.238.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0251.hostedemail.com ([216.40.44.251]:39854 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750980Ab3LKCP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 21:15:57 -0500
In-Reply-To: <1386726826.1516.238.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 01:53 +0000, Ben Hutchings wrote:
> From: Laurence Evans <levans@solarflare.com>
[]
> diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
[]
> @@ -270,6 +271,7 @@ struct efx_ptp_data {
>  	struct list_head evt_list;
>  	struct list_head evt_free_list;
>  	spinlock_t evt_lock;
> +	bool evt_overflow;

It might be nice to move the bools in this struct together
to reduce the number of struct holes.
