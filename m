From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.34-rc5] smc91c92_cs: spin_unlock_irqrestore
 before calling smc_interrupt()
Date: Tue, 27 Apr 2010 14:47:57 -0700 (PDT)
Message-ID: <20100427.144757.26952054.davem@davemloft.net>
References: <20100404061434.eb98ef3e.ken_kawasaki@spring.nifty.jp>
	<20100411075014.d3e80847.ken_kawasaki@spring.nifty.jp>
	<20100425053709.ec182f63.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757013Ab0D0Vrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:47:52 -0400
In-Reply-To: <20100425053709.ec182f63.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 25 Apr 2010 05:37:09 +0900

> 
> smc91c92_cs:
>   * spin_unlock_irqrestore before calling smc_interrupt() in media_check()
>      to avoid lockup.
>   * use spin_lock_irqsave for ethtool function.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thank you.
