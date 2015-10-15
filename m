From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid spurious SYN flood detection at
 listen() time
Date: Wed, 14 Oct 2015 19:09:10 -0700 (PDT)
Message-ID: <20151014.190910.46060543822756241.davem@davemloft.net>
References: <1444828609.4166.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbbJOBxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:53:04 -0400
In-Reply-To: <1444828609.4166.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Oct 2015 06:16:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> At listen() time, there is a small window where listener is visible with
> a zero backlog, triggering a spurious "Possible SYN flooding on port"
> message.
> 
> Nothing prevents us from setting the correct backlog.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
