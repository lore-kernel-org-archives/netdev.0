From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/15] sfc: Tidy up PTP synchronization code
Date: Sat, 14 Dec 2013 22:30:51 -0500 (EST)
Message-ID: <20131214.223051.2070299021185811869.davem@davemloft.net>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
	<1387062159.12172.64.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	richardcochran@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab3LODax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 22:30:53 -0500
In-Reply-To: <1387062159.12172.64.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 14 Dec 2013 23:02:39 +0000

> @@ -435,7 +435,6 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
>  		MCDI_VAR_ARRAY_LEN(response_length,
>  				   PTP_OUT_SYNCHRONIZE_TIMESET);
>  	unsigned i;
> -	unsigned total;
>  	unsigned ngood = 0;
>  	unsigned last_good = 0;

Please at some point fix this code to use an explicit "unsigned int".

Thanks.
