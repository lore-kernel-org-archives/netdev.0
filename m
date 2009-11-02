From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] bridge: check address size
Date: Mon, 02 Nov 2009 00:07:56 -0800 (PST)
Message-ID: <20091102.000756.222203879.davem@davemloft.net>
References: <846C5B546E47494CBBD796CA8CA1617EA3B431@MST-VMAIL1.srv.mst.edu>
	<20091029151222.156945ca@nehalam>
	<20091029152408.6c6cc29f@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nneul@mst.edu, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45476
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754064AbZKBIHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 03:07:32 -0500
In-Reply-To: <20091029152408.6c6cc29f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 29 Oct 2009 15:24:08 -0700

> -	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
> +	/* Don't allow bridging non ethernet like devices */
> +	if (dev->flags & IFF_LOOPBACK
> +	    || dev->type != ARPHRD_ETHER
> +	    || dev->addr_len != ETH_ALEN)

Please format this as:

> +	if (dev->flags & IFF_LOOPBACK ||
> +	    dev->type != ARPHRD_ETHER ||
> +	    dev->addr_len != ETH_ALEN)

What you're doing in the patch follows the GNU coding standards, no
the kernel ones. :-)
