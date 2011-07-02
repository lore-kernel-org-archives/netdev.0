From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v3][net][bna] Fix call trace when interrupts are
 disabled while sleeping function kzalloc is called
Date: Fri, 01 Jul 2011 17:50:12 -0700 (PDT)
Message-ID: <20110701.175012.338240104084578173.davem@davemloft.net>
References: <1309287485-6077-1-git-send-email-shyam_iyer@dell.com>
	<E5313AF6F2BFD14293E5FD0F94750F86A82D66F782@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shyam.iyer.t@gmail.com, netdev@vger.kernel.org, ddutt@brocade.com,
	huangj@brocade.com, shyam_iyer@dell.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661Ab1GBAvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 20:51:18 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A82D66F782@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 28 Jun 2011 16:32:58 -0700

>>From: Shyam Iyer [mailto:shyam.iyer.t@gmail.com]
>>Sent: Tuesday, June 28, 2011 11:58 AM
>>
>>request_threaded irq will call kzalloc that can sleep. Initializing the
>>flags variable outside of spin_lock_irqsave/restore in
>>bnad_mbox_irq_alloc will avoid call traces like below.
 ...
> Patch looks fine.
> 
> Acked-by: Rasesh Mody <rmody@brocade.com>

Applied, thanks
