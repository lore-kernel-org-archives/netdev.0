From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnx2: Free IRQ before freeing status
 block memory
Date: Fri, 31 Dec 2010 11:04:14 -0800 (PST)
Message-ID: <20101231.110414.59672398.davem@davemloft.net>
References: <1293157320-13758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622Ab0LaTDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 14:03:43 -0500
In-Reply-To: <1293157320-13758-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 23 Dec 2010 18:21:59 -0800

> When changing ring size, we free all memory including status block
> memory.  If we're in INTA mode and sharing IRQ, the IRQ handler can
> be called and it will reference the NULL status block pointer.
> 
> Because of the lockless design of the IRQ handler, there is no simple
> way to synchronize and prevent this.  So we avoid this problem by
> freeing the IRQ handler before freeing the status block memory.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
