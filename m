From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Rename tunnel-mode functions to avoid collisions with
 tunnels
Date: Thu, 20 Dec 2007 13:54:13 -0800 (PST)
Message-ID: <20071220.135413.63512009.davem@davemloft.net>
References: <20071219063833.GA7041@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38278
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762529AbXLTVyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 16:54:14 -0500
In-Reply-To: <20071219063833.GA7041@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 19 Dec 2007 14:38:33 +0800

> [IPSEC]: Rename tunnel-mode functions to avoid collisions with tunnels
> 
> It appears that I've managed to create two different functions both
> called xfrm6_tunnel_output.  This is because we have the plain tunnel
> encapsulation named xfrmX_tunnel as well as the tunnel-mode encapsulation
> which lives in the files xfrmX_mode_tunnel.c.
> 
> This patch renames functions from the latter to use the xfrmX_mode_tunnel
> prefix to avoid name-space conflicts.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
