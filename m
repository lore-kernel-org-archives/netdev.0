From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 01/17] sfc: Reduce log level for MCDI
 error response in efx_mcdi_rpc()
Date: Fri, 03 Dec 2010 09:08:32 -0800 (PST)
Message-ID: <20101203.090832.193720176.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333569.3259.24.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42651
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751224Ab0LCRIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:08:06 -0500
In-Reply-To: <1291333569.3259.24.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:46:09 +0000

> Some errors are expected, e.g. when sending new commands to an MC
> running old firmware.  Only the caller of efx_mcdi_rpc() can decide
> what is a real error.  Therefore log the error responses with
> netif_dbg().
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
