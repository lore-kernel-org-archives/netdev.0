From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cs89x0: Always report failure to request interrupt
Date: Thu, 07 Jan 2010 00:53:12 -0800 (PST)
Message-ID: <20100107.005312.243284287.davem@davemloft.net>
References: <1262690210-20763-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932546Ab0AGIxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 03:53:04 -0500
In-Reply-To: <1262690210-20763-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Tue,  5 Jan 2010 11:16:50 +0000

> A failure on request_irq() is always fatal but unlike other fatal
> errors it's only reported to the user if net_debug is set. Make the
> diagnostic unconditional and raise the priority so that errors are
> more obvious to the user.
> 
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Applied, thanks.
