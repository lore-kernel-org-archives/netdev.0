From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: udp_unhash() can test if sk is hashed
Date: Tue, 25 Nov 2008 13:55:30 -0800 (PST)
Message-ID: <20081125.135530.251944444.davem@davemloft.net>
References: <492C5F53.2090901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57974
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752716AbYKYVza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 16:55:30 -0500
In-Reply-To: <492C5F53.2090901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 25 Nov 2008 21:25:55 +0100

> Impact: Optimization
> 
> Like done in inet_unhash(), we can avoid taking a chain lock if
> socket is not hashed in udp_unhash()
> 
> Triggered by close(socket(AF_INET, SOCK_DGRAM, 0));
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
