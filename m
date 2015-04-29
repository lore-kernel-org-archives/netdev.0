From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] altera_tse: Correct rx packet length
Date: Wed, 29 Apr 2015 15:20:05 -0400 (EDT)
Message-ID: <20150429.152005.1070579390412301565.davem@davemloft.net>
References: <554006E7.1050806@vsis.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org
To: setka@vsis.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbD2TUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:20:08 -0400
In-Reply-To: <554006E7.1050806@vsis.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlastimil Setka <setka@vsis.cz>
Date: Wed, 29 Apr 2015 00:17:11 +0200

> From: Vlastimil Setka <setka@vsis.cz>
> 
> Altera TSE MAC rx DMA transfer starts with the 2 additional bytes for IP
> payload alignment. This patch fixes tse_rx() function loop which reads DMA
> rx status and extracts packet length from it. Status signalises a whole DMA
> transfer length, which is 2 bytes longer than the packet itself.
> 
> Signed-off-by: Vlastimil Setka <setka@vsis.cz>

Applied, thank you.
