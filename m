From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: Set ip_summed correctly for page buffers
 passed to GRO
Date: Wed, 28 Oct 2009 03:44:01 -0700 (PDT)
Message-ID: <20091028.034401.179608358.davem@davemloft.net>
References: <1256655057.2794.4.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751040AbZJ1Knl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:43:41 -0400
In-Reply-To: <1256655057.2794.4.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 27 Oct 2009 14:50:57 +0000

> Page buffers containing packets with an incorrect checksum or using a
> protocol not handled by hardware checksum offload were previously not
> passed to LRO.  The conversion to GRO changed this, but did not set
> the ip_summed value accordingly.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

> This affects 2.6.31 and seems like a candidate for a stable update.

Queued up for -stable, thanks.
