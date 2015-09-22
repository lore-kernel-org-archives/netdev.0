From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: add ethtool support to read and change
 RSS key
Date: Tue, 22 Sep 2015 14:59:35 -0700 (PDT)
Message-ID: <20150922.145935.2262486270670808983.davem@davemloft.net>
References: <1442614912.14037.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934882AbbIVV7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 17:59:39 -0400
In-Reply-To: <1442614912.14037.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Sep 2015 15:21:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While trying to understand why bnx2x RSS hash was not matching
> Toeplitz specifications, I implemented driver code to support
> ethtool -x|-X to try various RSS key combinations easily.
> 
> Then, after some debugging, I understood bnx2x was reading the rss_key
> in reverse order.
> 
> If we want consistent Toeplitz hashes with different NIC, we need
> to byte swap user key.
> 
> Tested:
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
