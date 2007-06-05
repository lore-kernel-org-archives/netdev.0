From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP : use LIMIT_NETDEBUG in tcp_retransmit_timer()
Date: Tue, 05 Jun 2007 00:00:27 -0700 (PDT)
Message-ID: <20070605.000027.59657229.davem@davemloft.net>
References: <4663BBA4.70009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45133
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761567AbXFEHAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 03:00:13 -0400
In-Reply-To: <4663BBA4.70009@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 04 Jun 2007 09:13:40 +0200

> LIMIT_NETDEBUG allows the admin to disable some warning messages (echo 0 
>  >/proc/sys/net/core/warnings).
> 
> The "TCP: Treason uncloaked!" message can use this facility.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

That's pretty difficult to trigger remotely, and the last time
we saw a legitimate case of this it was actually a bug in the
Linux TCP stack which we've long since fixed.

I would rather not let people easily disable this, since it
finds bugs and I can't see someone seriously exploiting this
to spam your logs.

I suppose you disagree :)
