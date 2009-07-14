From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 14 Jul 2009 12:34:05 -0700 (PDT)
Message-ID: <20090714.123405.181074517.davem@davemloft.net>
References: <20090714.122704.21107059.davem@davemloft.net>
	<20090714203123.0ab1f7b8@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752597AbZGNTeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:34:01 -0400
In-Reply-To: <20090714203123.0ab1f7b8@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 14 Jul 2009 20:31:23 +0100

>> 8) Locking fix in TTY based networking drivers, from Ralf Baechle.
> 
> I thought we had established that this one was wrong following further
> discussion. The tty drivers that were calling up from IRQ handlers have
> been fixed by the cull of bogus tty->low_latency setting.

Where was this change made?

At a minimum it likely needs to be added to the -stable trees.
