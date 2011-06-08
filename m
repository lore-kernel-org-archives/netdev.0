From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] xfrm: Fix off by one in the replay advance
 functions
Date: Tue, 07 Jun 2011 21:15:17 -0700 (PDT)
Message-ID: <20110607.211517.2153210229002058480.davem@davemloft.net>
References: <20110606064603.GB31505@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab1FHEPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 00:15:32 -0400
In-Reply-To: <20110606064603.GB31505@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 6 Jun 2011 08:46:03 +0200

> We may write 4 byte too much when we reinitialize the anti replay
> window in the replay advance functions. This patch fixes this by
> adjusting the last index of the initialization loop.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks.
