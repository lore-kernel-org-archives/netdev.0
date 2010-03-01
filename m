From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] cxgb4: driver submission V4
Date: Sun, 28 Feb 2010 18:59:47 -0800 (PST)
Message-ID: <20100228.185947.88334097.davem@davemloft.net>
References: <1267373385-1665-1-git-send-email-dm@chelsio.com>
	<20100228.183000.161196735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36828
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752363Ab0CAC73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 21:59:29 -0500
In-Reply-To: <20100228.183000.161196735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 28 Feb 2010 18:30:00 -0800 (PST)

> From: Dimitris Michailidis <dm@chelsio.com>
> Date: Sun, 28 Feb 2010 08:09:38 -0800
> 
>> 
>> This is V4 of the cxgb4 patches, which is V3 with need_skb_unmap removed.
> 
> Applied.

Nevermind, reverted.

You're not build testing your changes either:

drivers/net/cxgb4/cxgb4_main.c: In function 'cxgb_netpoll':
drivers/net/cxgb4/cxgb4_main.c:3470: warning: pointer type mismatch in conditional expression
drivers/net/cxgb4/cxgb4_main.c:3470: warning: passing argument 1 of 't4_intr_handler(adap)' makes integer from pointer without a cast
drivers/net/cxgb4/cxgb4_main.c:3470: note: expected 'int' but argument is of type 'void *'
drivers/net/cxgb4/cxgb4_main.c:3470: error: too few arguments to function 't4_intr_handler(adap)'
make[3]: *** [drivers/net/cxgb4/cxgb4_main.o] Error 1
make[3]: *** Waiting for unfinished jobs....

You know, I really can't believe people not only bomb me with all of
this last minute networking crap, but on top of it they are also doing
so with such poorly tested changes.

Stuff that doesn't even friggin' build!
