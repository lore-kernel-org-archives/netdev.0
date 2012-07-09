From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem: add limitation to reordered packets
Date: Mon, 09 Jul 2012 00:02:12 -0700 (PDT)
Message-ID: <20120709.000212.14587878724925750.davem@davemloft.net>
References: <1341384921.2583.1462.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, msg@google.com,
	aterzis@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155Ab2GIHCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:02:13 -0400
In-Reply-To: <1341384921.2583.1462.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Jul 2012 08:55:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Fix two netem bugs :
> 
> 1) When a frame was dropped by tfifo_enqueue(), drop counter
>    was incremented twice.
> 
> 2) When reordering is triggered, we enqueue a packet without
>    checking queue limit. This can OOM pretty fast when this
>    is repeated enough, since skbs are orphaned, no socket limit
>    can help in this situation.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
