From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/5] alx: add a hardware stats structure
Date: Thu, 2 Jan 2014 11:52:11 +0000
Message-ID: <1388663531.22017.7.camel@deadeye.wl.decadent.org.uk>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-2-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22015 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbaABLwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 06:52:16 -0500
In-Reply-To: <1388619628-3373-2-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 00:40 +0100, Sabrina Dubroca wrote:
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>  drivers/net/ethernet/atheros/alx/hw.h | 58 +++++++++++++++++++++++++++++++++++
>  1 file changed, 58 insertions(+)
> 
> diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
> index 96f3b43..207bcc6 100644
> --- a/drivers/net/ethernet/atheros/alx/hw.h
> +++ b/drivers/net/ethernet/atheros/alx/hw.h
> @@ -381,6 +381,64 @@ struct alx_rrd {
>  				 ALX_ISR_RX_Q6 | \
>  				 ALX_ISR_RX_Q7)
>  
> +/* Statistics counters collected by the MAC */
> +struct alx_hw_stats {
> +	/* rx */
> +	unsigned long rx_ok;
[...]

Use u64 for all of these.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
