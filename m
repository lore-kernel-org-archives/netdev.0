From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Tue, 13 Aug 2013 15:09:55 -0700 (PDT)
Message-ID: <20130813.150955.1471100759610399160.davem@davemloft.net>
References: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net>
	<20130810.132935.1257046025460198490.davem@davemloft.net>
	<20130810150207.37432299@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pomidorabelisima@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759033Ab3HMWJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:09:56 -0400
In-Reply-To: <20130810150207.37432299@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 10 Aug 2013 15:02:07 -0700

> The DMA sync should sync the whole receive buffer, not just
> part of it. Fixes log messages dma_sync_check.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, but I really suspect that your "check DMA mapping errors"
patch has added a serious regression.  A regression much worse than
the bug you were trying to fix with that change.
