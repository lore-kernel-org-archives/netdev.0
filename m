From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ibm emac: Don't call napi_complete if
 napi_reschedule failed
Date: Tue, 29 Oct 2013 22:58:21 -0400 (EDT)
Message-ID: <20131029.225821.1638134357101864736.davem@davemloft.net>
References: <1383090638-21526-1-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
To: alistair@popple.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab3J3C6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:58:23 -0400
In-Reply-To: <1383090638-21526-1-git-send-email-alistair@popple.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alistair Popple <alistair@popple.id.au>
Date: Wed, 30 Oct 2013 10:50:37 +1100

> This patch fixes a bug which would trigger the BUG_ON() at
> net/core/dev.c:4156. It was found that this was due to continuing
> processing in the current poll call even when the call to
> napi_reschedule failed, indicating the device was already on the
> polling list. This resulted in an extra call to napi_complete which
> triggered the BUG_ON().
> 
> This patch ensures that we only contine processing rotting packets in
> the current mal_poll call if we are not already on the polling list.
> 
> Signed-off-by: Alistair Popple <alistair@popple.id.au>

Applied.
