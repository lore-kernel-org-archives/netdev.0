From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Tue, 08 Dec 2009 20:46:48 -0800 (PST)
Message-ID: <20091208.204648.38101137.davem@davemloft.net>
References: <4B1A4E07.4030804@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756844AbZLIEqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:46:42 -0500
In-Reply-To: <4B1A4E07.4030804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 Dec 2009 13:11:51 +0100

> - Use atomic_dec_and_test() in inet_putpeer()
>   This takes/dirties the lock only if necessary.
> 
> - Group fields together, since they currently are in BSS and DATA section,
>   we have to dirty two cache lines instead of one.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Eric please resubmit this when net-next-2.6 opens back up.

Maybe add some comments so that people won't be confused about
semantics like Jarek was :-)
