From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Spread rx buffers between allocated
 queues
Date: Mon, 13 Sep 2010 20:04:41 -0700 (PDT)
Message-ID: <20100913.200441.258119112.davem@davemloft.net>
References: <1284306508.5534.1.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49755
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753662Ab0INDEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 23:04:22 -0400
In-Reply-To: <1284306508.5534.1.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sun, 12 Sep 2010 17:48:28 +0200

>  Default number of rx buffers will be divided equally
>  between allocated queues. This will decrease amount of
>  pre-allocated buffers on systems with multiple CPUs.
>  User can override this behavior with ethtool -G.
>  Minimum amount of rx buffers per queue set to 128.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thank you.
