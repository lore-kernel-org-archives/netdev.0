From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] sfc: Feed GRO result into RX allocation policy and
 interrupt moderation
Date: Thu, 29 Oct 2009 21:33:16 -0700 (PDT)
Message-ID: <20091029.213316.239341636.davem@davemloft.net>
References: <1256836884.2827.73.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56788
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751632AbZJ3Ecv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 00:32:51 -0400
In-Reply-To: <1256836884.2827.73.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 29 Oct 2009 17:21:24 +0000

> When GRO is successfully merging received packets, we should allocate
> raw page buffers rather than skbs that will be discarded by GRO.
> Otherwise, we should allocate skbs.
> 
> GRO also benefits from higher interrupt moderation, so increase the
> score for mergeable RX packets.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

I'll pull net-2.6 into net-next-2.6 before applying this patch and the
next one.

But you need to tell me that such dependencies exist when you submit
patches like this, ok?
