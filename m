From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: set qdisc_tx_busylock to avoid LOCKDEP splat
Date: Thu, 04 Oct 2012 15:54:36 -0400 (EDT)
Message-ID: <20121004.155436.2187376781654738552.davem@davemloft.net>
References: <1349342319.16011.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpirko@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757409Ab2JDTyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 15:54:38 -0400
In-Reply-To: <1349342319.16011.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Oct 2012 11:18:39 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> If a qdisc is installed on a team device, its possible to get
> a lockdep splat under stress, because nested dev_queue_xmit() can
> lock busylock a second time (on a different device, so its a false
> positive)
> 
> Avoid this problem using a distinct lock_class_key for team
> devices.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jiri Pirko <jpirko@redhat.com>

Applied.
