From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6] net/ethtool: add multiple queue support to
 {get,set}_ringparams
Date: Sat, 13 Mar 2010 18:11:45 -0800 (PST)
Message-ID: <20100313.181145.211264593.davem@davemloft.net>
References: <20100314014335.GA17208@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36762
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751155Ab0CNCLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 21:11:23 -0500
In-Reply-To: <20100314014335.GA17208@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Sun, 14 Mar 2010 07:13:45 +0530

> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index b33f316..de6a90a 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -206,6 +206,7 @@ struct ethtool_coalesce {
>  /* for configuring RX/TX ring parameters */
>  struct ethtool_ringparam {
>  	__u32	cmd;	/* ETHTOOL_{G,S}RINGPARAM */
> +	__u32	ring_id;
>  
>  	/* Read only attributes.  These indicate the maximum number
>  	 * of pending RX/TX ring entries the driver will allow the

For the millionth time, you cannot change these datastructures
like this without breaking all existing userspace applications
out there.
