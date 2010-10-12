From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Tue, 12 Oct 2010 11:51:38 -0700 (PDT)
Message-ID: <20101012.115138.112614145.davem@davemloft.net>
References: <20101009095346.GA12951@hera.kernel.org>
	<20101009132749.GA15074@solarflare.com>
	<4CB0C56C.2000106@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: dkirjanov@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753104Ab0JLSvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 14:51:16 -0400
In-Reply-To: <4CB0C56C.2000106@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@kernel.org>
Date: Sat, 09 Oct 2010 23:41:32 +0400

> +	/* ethtool extra stats */
> +	struct {
> +		unsigned long tx_multiple_collisions;
> +		unsigned long tx_single_collisions;
> +		unsigned long tx_late_collisions;
> +		unsigned long tx_deffered;
> +		unsigned long tx_deffered_excessive;
> +		unsigned long tx_aborted;
> +		unsigned long tx_bcasts;
> +		unsigned long rx_bcasts;
> +		unsigned long tx_mcasts;
> +		unsigned long rx_mcasts;
> +	} xstats;

I think these should be "u64".
