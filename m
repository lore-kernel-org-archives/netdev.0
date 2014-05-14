From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: Fix unmap loop counting error:
Date: Wed, 14 May 2014 15:11:57 -0400 (EDT)
Message-ID: <20140514.151157.333839321283028293.davem@davemloft.net>
References: <1399905498-27691-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	cooldavid@cooldavid.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaENTL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:11:59 -0400
In-Reply-To: <1399905498-27691-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 12 May 2014 10:38:18 -0400

> In my recent fix (76a691d0a: fix dma unmap warning), Ben Hutchings noted that my
> loop count was incorrect.  Where j started at startidx, it should have started
> at zero, and gone on for count entries, not to endidx.  Additionally, a DMA
> resource exhaustion should drop the frame and (for now), return
> NETDEV_TX_OK, not NETEV_TX_BUSY.  This patch fixes both of those issues:
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
