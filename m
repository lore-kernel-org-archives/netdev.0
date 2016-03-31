From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Do not access unexisting register in Coldfire
Date: Thu, 31 Mar 2016 16:46:35 -0400 (EDT)
Message-ID: <20160331.164635.2025583994422727303.davem@davemloft.net>
References: <1459436717-12809-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
	gerg@uclinux.org, netdev@vger.kernel.org, fabio.estevam@nxp.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757428AbcCaUqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 16:46:39 -0400
In-Reply-To: <1459436717-12809-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Thu, 31 Mar 2016 12:05:17 -0300

> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Commit 55cd48c821de ("net: fec: stop the "rcv is not +last, " error
> messages") introduces a write to a register that does not exist in
> Coldfire.
> 
> Move the FEC_FTRL register access inside the FEC_QUIRK_HAS_RACC 'if' block,
> so that we guarantee it will not be used on Coldfire CPUs.
> 
> Reported-by: Greg Ungerer <gerg@uclinux.org>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Applied, thanks.
