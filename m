From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] can: SJA1000 add missing spin_lock_init()
Date: Thu, 20 May 2010 23:21:55 -0700 (PDT)
Message-ID: <20100520.232155.150173423.davem@davemloft.net>
References: <4BF415EE.8090307@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	sam@ravnborg.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48168
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754136Ab0EUGVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 02:21:45 -0400
In-Reply-To: <4BF415EE.8090307@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 19 May 2010 18:46:38 +0200

> As remarked by Sam Ravnborg the spin_lock variable, that has been introduced
> in commit 57c8a456640fa3ca777652f11f2db4179a3e66b6 ("can: Fix SJA1000 command
> register writes on SMP systems") has not been initialized properly.
> 
> This patch adds the initialization to allow spinlock debugging. 
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, thanks!
