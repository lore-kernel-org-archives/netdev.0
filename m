From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fec: Call swap_buffer() prior to IP header
 alignment
Date: Sun, 23 Oct 2016 17:42:27 -0400 (EDT)
Message-ID: <20161023.174227.853585114262094271.davem@davemloft.net>
References: <1477049669-25101-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, henri.roosen@ginzinger.com, eric@nelint.com,
        kernel@pengutronix.de, rmk@armlinux.org.uk, netdev@vger.kernel.org,
        fabio.estevam@nxp.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbcJWVm3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 17:42:29 -0400
In-Reply-To: <1477049669-25101-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri, 21 Oct 2016 09:34:29 -0200

> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Commit 3ac72b7b63d5 ("net: fec: align IP header in hardware") breaks
> networking on mx28.
> 
> There is an erratum on mx28 (ENGR121613 - ENET big endian mode
> not compatible with ARM little endian) that requires an additional
> byte-swap operation to workaround this problem.
> 
> So call swap_buffer() prior to performing the IP header alignment
> to restore network functionality on mx28. 
> 
> Fixes: 3ac72b7b63d5 ("net: fec: align IP header in hardware")
> Reported-and-tested-by: Henri Roosen <henri.roosen@ginzinger.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Applied, thank you.
