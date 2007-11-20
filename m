From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/11] netpoll: NETPOLL_TRAP configuration change
Date: Mon, 19 Nov 2007 19:52:51 -0800 (PST)
Message-ID: <20071119.195251.11058745.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.873309086@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751068AbXKTDww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 22:52:52 -0500
In-Reply-To: <20071103184338.873309086@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:22 -0700

> --- a/drivers/net/Kconfig	2007-11-03 11:30:57.000000000 -0700
> +++ b/drivers/net/Kconfig	2007-11-03 11:30:59.000000000 -0700
> @@ -3118,8 +3118,8 @@ config NETCONSOLE_DYNAMIC
>  config NETPOLL
>  	def_bool NETCONSOLE
>  
> +# If needed use select to enable
>  config NETPOLL_TRAP
> -	bool "Netpoll traffic trapping"
>  	default n
>  	depends on NETPOLL

I'm not applying this.

This change means that allmodconfig doesn't pick up this symbol
anymore and therefore it's way to difficult to make sure these
code segments still get build tested.
