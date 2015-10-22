From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fastopen: limit max_qlen
Date: Thu, 22 Oct 2015 06:22:33 -0700 (PDT)
Message-ID: <20151022.062233.2239077872274900749.davem@davemloft.net>
References: <1445372260.22974.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbbJVNGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:06:06 -0400
In-Reply-To: <1445372260.22974.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Oct 2015 13:17:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Allowing an application to set whatever limit for
> the list of recently RST fastopen sessions [1] is not wise,
> as it open ways to deplete kernel memory.
> 
> Cap the user provided limit by somaxconn sysctl,
> like listen() backlog.
> 
> [1] https://tools.ietf.org/html/rfc7413#section-5.1
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
