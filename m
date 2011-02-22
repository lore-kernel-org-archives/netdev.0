From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax88796: depend on HAS_IOMEM not on individual ARCHs
Date: Tue, 22 Feb 2011 14:01:40 -0800 (PST)
Message-ID: <20110222.140140.232738034.davem@davemloft.net>
References: <1298405998-6214-1-git-send-email-mkl@pengutronix.de>
	<20110222.123732.70186533.davem@davemloft.net>
	<4D642DC6.2010307@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38884
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752040Ab1BVWBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 17:01:04 -0500
In-Reply-To: <4D642DC6.2010307@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 22 Feb 2011 22:42:30 +0100

> On 02/22/2011 09:37 PM, David Miller wrote:
>> I know it's going to cause allmodconfig build errors on sparc64,
>> for example.
> 
> How to fix?
>> drivers/net/ax88796.c:195: error: implicit declaration of function 'readsw'
>> drivers/net/ax88796.c:198: error: implicit declaration of function 'readsb'
> 
> Use "ioreadX_rep" or add a "!SPARC64" to Kconfig?

Make sparc64 provide the necessary interface.
