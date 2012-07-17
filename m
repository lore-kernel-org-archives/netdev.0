From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fix rcu splat
Date: Tue, 17 Jul 2012 13:49:38 -0700 (PDT)
Message-ID: <20120717.134938.1399098772864579804.davem@davemloft.net>
References: <1342557733.2626.1103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717Ab2GQUtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 16:49:39 -0400
In-Reply-To: <1342557733.2626.1103.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jul 2012 22:42:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> free_nh_exceptions() should use rcu_dereference_protected(..., 1)
> since its called after one RCU grace period.
> 
> Also add some const-ification in recent code.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
