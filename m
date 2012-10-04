From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: set qdisc_tx_busylock to avoid LOCKDEP splat
Date: Thu, 04 Oct 2012 15:54:23 -0400 (EDT)
Message-ID: <20121004.155423.1912786546830082596.davem@davemloft.net>
References: <1349341526.16011.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757249Ab2JDTyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 15:54:25 -0400
In-Reply-To: <1349341526.16011.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Oct 2012 11:05:26 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> If a qdisc is installed on a bonding device, its possible to get
> following lockdep splat under stress :
 ...
> Avoid this problem using a distinct lock_class_key for bonding
> devices.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
