From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Revert "make the RX_FILTER command
 asynchronous" commit
Date: Sat, 05 Sep 2015 22:01:39 -0700 (PDT)
Message-ID: <20150905.220139.10413461941504850.davem@davemloft.net>
References: <1441280513-27531-1-git-send-email-sathya.perla@avagotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbbIFFBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 01:01:45 -0400
In-Reply-To: <1441280513-27531-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@avagotech.com>
Date: Thu,  3 Sep 2015 07:41:53 -0400

> The be_cmd_rx_filter() routine sends a non-embedded cmd to the FW and used
> a pre-allocated dma memory to hold the cmd payload. This worked fine when
> this cmd was synchronous. This cmd was changed to asynchronous mode by the
> commit 8af65c2f4("make the RX_FILTER command asynchronous"). So now when
> there are two quick invocations of this cmd, the 2nd request may end up
> overwriting the first request, causing FW cmd corruption.
> 
> This patch reverts the offending commit and hence fixes the regression.
> 
> Fixes: 8af65c2f4("be2net: make the RX_FILTER command asynchronous")
> Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>

Applied, thanks.
