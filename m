From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: use spin_trylock_irqsave()
Date: Tue, 07 Aug 2007 17:18:57 -0400
Message-ID: <46B8E1C1.8040903@garzik.org>
References: <11859268222715-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, csnook@redhat.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nando@ccrma.Stanford.EDU, tglx@linutronix.de, brbrofsvl@gmail.com
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45884 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936995AbXHGVTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 17:19:10 -0400
In-Reply-To: <11859268222715-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> From: Ingo Molnar <mingo@elte.hu>
> 
> use the simpler spin_trylock_irqsave() API to get the adapter lock.
> 
> [ this is also a fix for -rt where adapter->lock is a sleeping lock. ]
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/atl1/atl1_main.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)

applied to #upstream-fixes


