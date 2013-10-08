From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Tue, 08 Oct 2013 16:04:46 -0400 (EDT)
Message-ID: <20131008.160446.1960731810404939922.davem@davemloft.net>
References: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ryusuke.sakato.bx@renesas.com,
	sergei.shtylyov@cogentembedded.com, horms@verge.net.au
To: nh-ky@jinso.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab3JHUEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:04:48 -0400
In-Reply-To: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nguyen Hong Ky <nh-ky@jinso.co.jp>
Date: Mon,  7 Oct 2013 15:29:24 +0900

> This patch will fix RX packets errors when receiving big size of data.
> Moreover, I set suitable parameters for get more stable when receiving
> packets.
> 
> It was created on the top of mainline kernel v3.11.
> 
> I tested this patch on Armadillo800eva, it appears to be working well.
> 
> Would you please review and apply it for me.

Applied, but at some point someone has to add definitions for the
RMCR register fields so that this driver is not full of magic constants.
