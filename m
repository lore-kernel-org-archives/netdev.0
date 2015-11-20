From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] ravb: use clock rate as basis for GTI.TIV
Date: Fri, 20 Nov 2015 14:53:08 -0500 (EST)
Message-ID: <20151120.145308.462101495816748076.davem@davemloft.net>
References: <1448047779-21242-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	magnus.damm@gmail.com
To: horms+renesas@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760027AbbKTTxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 14:53:10 -0500
In-Reply-To: <1448047779-21242-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms+renesas@verge.net.au>
Date: Fri, 20 Nov 2015 11:29:39 -0800

> The GTI.TIV may be set to 2GHz^2 / rate, where rate is
> that of the clock of the device. Rather than assuming a
> rate of 130MHz use the actual rate of the clock.
> 
> The motivation for this is to use the correct rate on
> the r8a7795/Salvator-X which is advertised as 133MHz but
> may differ depending on the extal present on the Salvator-X.
> 
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Applied, thanks Simon.
