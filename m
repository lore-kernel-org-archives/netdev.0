From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 05/13] ip: support for TX timestamps on UDP and RAW
 sockets
Date: Wed, 12 Nov 2008 01:59:52 -0800 (PST)
Message-ID: <20081112.015952.170520598.davem@davemloft.net>
References: <1226414697.17450.852.camel@ecld0pohly>
	<1226415422.31699.4.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@axxeo.de, ak@linux.intel.com,
	john.ronciak@intel.com, dada1@cosmosbay.com, oliver@hartkopp.net
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751576AbYKLJ7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 04:59:53 -0500
In-Reply-To: <1226415422.31699.4.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Fri, 24 Oct 2008 15:49:10 +0200

> diff --git a/include/net/ip.h b/include/net/ip.h
> index 250e6ef..76cee15 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -54,6 +54,7 @@ struct ipcm_cookie
>  	__be32			addr;
>  	int			oif;
>  	struct ip_options	*opt;
> +	union ktime		tstamp;
>  };
>  
>  #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))

Please use ktime_t
