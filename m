From: David Miller <davem@davemloft.net>
Subject: Re: Fix build failure with 'make mandocs'.
Date: Tue, 22 Jul 2008 14:06:11 -0700 (PDT)
Message-ID: <20080722.140611.239206634.davem@davemloft.net>
References: <20080721205229.GA26812@redhat.com>
	<20080722132439.dfbd6597.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49350
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755469AbYGVVGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:06:11 -0400
In-Reply-To: <20080722132439.dfbd6597.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 22 Jul 2008 13:24:39 -0700

> On Mon, 21 Jul 2008 16:52:29 -0400 Dave Jones wrote:
> 
> > The function header comments have to go with the functions
> > they are documenting, or things go horribly wrong when we
> > try to process them with the docbook tools.
> > 
> > Warning(include/linux/netdevice.h:1006): No description found for parameter 'dev_queue'
> > Warning(include/linux/netdevice.h:1033): No description found for parameter 'dev_queue'
> > Warning(include/linux/netdevice.h:1067): No description found for parameter 'dev_queue'
> > Warning(include/linux/netdevice.h:1093): No description found for parameter 'dev_queue'
> > Warning(include/linux/netdevice.h:1474): No description found for parameter 'txq'
> > Error(net/core/dev.c:1674): cannot understand prototype: 'u32 simple_tx_hashrnd; '
> > 
> > Signed-off-by: Dave Jones <davej@redhat.com>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> DaveM, please expedite since this Error is fatal (breaks 'make *docs').

Sure, will do.
