From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] text ematch: check for NULL pointer before destroying
 textsearch config
Date: Sun, 31 Oct 2010 09:38:00 -0700 (PDT)
Message-ID: <20101031.093800.104070726.davem@davemloft.net>
References: <20101031080635.GA22639@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756185Ab0JaQhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 12:37:36 -0400
In-Reply-To: <20101031080635.GA22639@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Sun, 31 Oct 2010 04:06:35 -0400

> While validating the configuration em_ops is already set, thus the
> individual destroy functions are called, but the ematch data has
> not been allocated and associated with the ematch yet.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Applied, thanks Thomas.
