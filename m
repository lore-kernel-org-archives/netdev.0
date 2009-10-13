From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-nex-2.6] tcp: replace ehash_size by ehash_mask
Date: Tue, 13 Oct 2009 03:46:05 -0700 (PDT)
Message-ID: <20091013.034605.109287815.davem@davemloft.net>
References: <4ACF0D73.9070809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49883
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759451AbZJMKqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:46:09 -0400
In-Reply-To: <4ACF0D73.9070809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Oct 2009 12:16:19 +0200

> Storing the mask (size - 1) instead of the size allows fast path to be a bit faster.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Fair enough, applied, thanks Eric.
