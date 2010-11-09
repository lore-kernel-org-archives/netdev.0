From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: normalize TX_TIMEOUT
Date: Tue, 09 Nov 2010 09:18:14 -0800 (PST)
Message-ID: <20101109.091814.183061559.davem@davemloft.net>
References: <1288860575.2659.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753587Ab0KIRRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 12:17:49 -0500
In-Reply-To: <1288860575.2659.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Nov 2010 09:49:35 +0100

> Some network drivers use old TX_TIMEOUT definitions, assuming HZ=100 of
> old kernels.
> 
> Convert these definitions to include HZ, since HZ can be 1000 these
> days.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
