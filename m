From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib_trie: use fls() instead of open coded loop
Date: Sat, 16 Oct 2010 11:55:59 -0700 (PDT)
Message-ID: <20101016.115559.115914722.davem@davemloft.net>
References: <1286988971.3876.974.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879Ab0JPSzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:55:37 -0400
In-Reply-To: <1286988971.3876.974.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Oct 2010 18:56:11 +0200

> fib_table_lookup() might use fls() to speedup an open coded loop.
> 
> Noticed while doing a profile analysis.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
