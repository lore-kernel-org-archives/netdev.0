From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Meth: Fix unsafe mix of irq and non-irq spinlocks.
Date: Sun, 17 May 2009 21:11:54 -0700 (PDT)
Message-ID: <20090517.211154.135580965.davem@davemloft.net>
References: <20090516112158.GA13140@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-mips@linux-mips.org,
	randrik_a@yahoo.com
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55175
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750783AbZEREL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:11:56 -0400
In-Reply-To: <20090516112158.GA13140@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sat, 16 May 2009 12:21:58 +0100

> Mixing of normal and irq spinlocks results in the following lockdep messages
> on bootup on IP32:
  ...
> Fixed by converting all locks to irq locks.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> Tested-by: Andrew Randrianasulu <randrik_a@yahoo.com>

Applied, thanks!
