From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: davinci_cpdma: decrease the desc count
 when cleaning up the remaining packets
Date: Tue, 02 Oct 2012 22:35:17 -0400 (EDT)
Message-ID: <20121002.223517.307096403144373535.davem@davemloft.net>
References: <1349145763-6292-1-git-send-email-hotforest@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hotforest@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab2JCCfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:35:18 -0400
In-Reply-To: <1349145763-6292-1-git-send-email-hotforest@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tao Hou <hotforest@gmail.com>
Date: Tue,  2 Oct 2012 10:42:43 +0800

> chan->count is used by rx channel. If the desc count is not updated by
> the clean up loop in cpdma_chan_stop, the value written to the rxfree
> register in cpdma_chan_start will be incorrect.
> 
> Signed-off-by: Tao Hou <hotforest@gmail.com>

Applied, thanks.
