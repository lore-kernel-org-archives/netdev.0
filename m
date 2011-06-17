From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fs_enet: fix freescale FCC ethernet dp buffer alignment
Date: Fri, 17 Jun 2011 15:21:23 -0400 (EDT)
Message-ID: <20110617.152123.620960460056800771.davem@davemloft.net>
References: <1308299439-5975-1-git-send-email-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, clive.stubbings@xentech.co.uk,
	pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	netdev@vger.kernel.org
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154Ab1FQTXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:23:38 -0400
In-Reply-To: <1308299439-5975-1-git-send-email-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Fri, 17 Jun 2011 10:30:39 +0200

> From: Clive Stubbings <clive.stubbings@xentech.co.uk>
> 
> The RIPTR and TIPTR  (receive/transmit internal temporary data pointer),
> used by microcode as a temporary buffer for data, must be 32-byte aligned
> according to the RM for MPC8247.
> 
> Tested on mgcoge.
> 
> Signed-off-by: Clive Stubbings <clive.stubbings@xentech.co.uk>
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
> cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
> cc: Vitaly Bordug <vbordug@ru.mvista.com>
> cc: netdev@vger.kernel.org

Applied, thanks.
