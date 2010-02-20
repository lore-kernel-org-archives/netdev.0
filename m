From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] sfc: Fix sign of efx_mcdi_poll_reboot()
 error in efx_mcdi_poll()
Date: Fri, 19 Feb 2010 17:03:00 -0800 (PST)
Message-ID: <20100219.170300.42888823.davem@davemloft.net>
References: <1266622168.2091.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751346Ab0BTBCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 20:02:44 -0500
In-Reply-To: <1266622168.2091.5.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 19 Feb 2010 23:29:27 +0000

> efx_mcdi_poll() uses positive error numbers, matching the MCDI
> protocol.  It must negate the result of efx_mcdi_poll_reboot() which
> returns the usual negative error numbers.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
