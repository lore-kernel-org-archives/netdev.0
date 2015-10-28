From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] sfc: replace spinlocks with bit ops
 for busy poll locking
Date: Tue, 27 Oct 2015 19:40:54 -0700 (PDT)
Message-ID: <20151027.194054.131642158609486935.davem@davemloft.net>
References: <562E376E.40904@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530AbbJ1CYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:24:13 -0400
In-Reply-To: <562E376E.40904@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Mon, 26 Oct 2015 14:23:42 +0000

> From: Bert Kenward <bkenward@solarflare.com>
> 
> This patch reduces the overhead of locking for busy poll.
> Previously the state was protected by a lock, whereas now
> it's manipulated solely with atomic operations.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
