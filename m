From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: introduce fib_alias_accessed() helper
Date: Thu, 21 Oct 2010 03:11:22 -0700 (PDT)
Message-ID: <20101021.031122.71113787.davem@davemloft.net>
References: <1287648218.6871.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754261Ab0JUKK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:10:59 -0400
In-Reply-To: <1287648218.6871.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Oct 2010 10:03:38 +0200

> Perf tools session at NFWS 2010 pointed out a false sharing on struct
> fib_alias that can be avoided pretty easily, if we set FA_S_ACCESSED bit
> only if needed (ie : not already set)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
