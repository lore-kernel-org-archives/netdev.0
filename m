From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 32/33] sfc: Fix synchronisation of
 efx_mtd_{probe,rename,remove}
Date: Fri, 12 Dec 2008 22:09:47 -0800 (PST)
Message-ID: <20081212.220947.90741433.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212130050.GF10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755340AbYLMGJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:09:46 -0500
In-Reply-To: <20081212130050.GF10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 13:00:51 +0000

> Currently efx_mtd_rename() can race with the probe() and remove()
> functions.
> 
> Move probe() before device registration and remove() after
> unregistration.  Move initialisation/update of all names based on the
> netdev name into a new function and call it under the RTNL immediately
> after registration.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
