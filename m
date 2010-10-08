From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Don't try to set filters with search
 depths we know won't work
Date: Fri, 08 Oct 2010 10:36:18 -0700 (PDT)
Message-ID: <20101008.103618.183055391.davem@davemloft.net>
References: <1286473831.2271.26.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35888
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759208Ab0JHRf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:35:57 -0400
In-Reply-To: <1286473831.2271.26.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 07 Oct 2010 18:50:31 +0100

> The filter engine will time-out and ignore filters beyond
> 200-something hops.  We also need to avoid infinite loops in
> efx_filter_search() when the table is full.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
