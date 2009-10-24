From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Dont leak kernel memory
Date: Sat, 24 Oct 2009 06:55:46 -0700 (PDT)
Message-ID: <20091024.065546.30924305.davem@davemloft.net>
References: <4ADE8C85.6020809@gmail.com>
	<4ADE95C6.40103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34624
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753504AbZJXNzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:55:23 -0400
In-Reply-To: <4ADE95C6.40103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Oct 2009 07:01:58 +0200

> [PATCH] pktgen: Dont leak kernel memory
> 
> While playing with pktgen, I realized IP ID was not filled and a random value
> was taken, possibly leaking 2 bytes of kernel memory.
>  
> We can use an increasing ID, this can help diagnostics anyway.
> 
> Also clear packet payload, instead of leaking kernel memory.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
