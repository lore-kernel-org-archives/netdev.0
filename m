From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: Really allow RX checksum offload to be
 disabled
Date: Wed, 28 Oct 2009 02:49:40 -0700 (PDT)
Message-ID: <20091028.024940.181264224.davem@davemloft.net>
References: <1256655057.2794.4.camel@achroite>
	<1256672673.2794.7.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751564AbZJ1JtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:49:16 -0400
In-Reply-To: <1256672673.2794.7.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 27 Oct 2009 19:44:33 +0000

> We have never checked the efx_nic::rx_checksum_enabled flag everywhere
> we should, and since the switch to GRO we don't check it anywhere.
> It's simplest to check it in the one place where we initialise the
> per-packet checksummed flag.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Cc: stable@kernel.org
> ---
> I'm not sure whether this is serious enough to merit a stable update.
> It's not a recent regression.

This patch only applies to net-next-2.6, so I can't see how it could
be a -stable candidate :-)

So I've applied it there.
