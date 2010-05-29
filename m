From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fs_enet: Adjust BDs after tx error
Date: Sat, 29 May 2010 00:16:36 -0700 (PDT)
Message-ID: <20100529.001636.42779529.davem@davemloft.net>
References: <4BFDC6EC.9090804@elphinstone.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	vbordug@ru.mvista.com, pantelis.antoniou@gmail.com
To: mware@elphinstone.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51263
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752312Ab0E2HQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 03:16:26 -0400
In-Reply-To: <4BFDC6EC.9090804@elphinstone.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Ware <mware@elphinstone.net>
Date: Thu, 27 May 2010 11:12:12 +1000

> This patch fixes an occasional transmit lockup in the mac-fcc which
> occurs after a tx error.  The test scenario had the local port set
> to autoneg and the other end fixed at 100FD, resulting in a large
> number of late collisions.
> 
> According to the MPC8280RM 30.10.1.3 (also 8272RM 29.10.1.3), after
> a tx error occurs, TBPTR may sometimes point beyond BDs still marked
> as ready.  This patch walks back through the BDs and points TBPTR to
> the earliest one marked as ready.
> 
> Tested on a custom board with a MPC8280.
> 
> Signed-off-by: Mark Ware <mware@elphinstone.net>

Applied, thanks.
