From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] Altera TSE: Fix DMA secriptor length
 initialization
Date: Wed, 30 Apr 2014 16:14:33 -0400 (EDT)
Message-ID: <20140430.161433.1833281012752521346.davem@davemloft.net>
References: <1398720181-19450-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridgers2013@gmail.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org
To: tobias.klauser@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965044AbaD3UOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:14:35 -0400
In-Reply-To: <1398720181-19450-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tobias.klauser@gmail.com>
Date: Mon, 28 Apr 2014 23:23:01 +0200

> sgdma_descrip is a function name as well as the name of a struct. In
> sgdma_initialize(), we should initialize the descriptor length field
> with the actual length of a descriptor not with the size of the
> function. In order to prevent such things from happening in the future,
> rename the function to sgdma_setup_descrip().
> 
> Found by sparse which yields the following warning:
> 
> drivers/net/ethernet/altera/altera_sgdma.c:74:30: warning: expression using sizeof on a function
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
