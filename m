From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] ethtool: Add support for control of
 RX flow hash indirection
Date: Wed, 30 Jun 2010 14:10:54 -0700 (PDT)
Message-ID: <20100630.141054.146101455.davem@davemloft.net>
References: <1277910323.2082.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756254Ab0F3VKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:10:40 -0400
In-Reply-To: <1277910323.2082.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jun 2010 16:05:23 +0100

> Many NICs use an indirection table to map an RX flow hash value to one
> of an arbitrary number of queues (not necessarily a power of 2).  It
> can be useful to remove some queues from this indirection table so
> that they are only used for flows that are specifically filtered
> there.  It may also be useful to weight the mapping to account for
> user processes with the same CPU-affinity as the RX interrupts.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Looks good, applied, thanks Ben.
