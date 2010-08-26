From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: reset the chip before freeing the buffers
Date: Thu, 26 Aug 2010 14:10:08 -0700 (PDT)
Message-ID: <20100826.141008.232759199.davem@davemloft.net>
References: <1282847278-23416-1-git-send-email-leitao@linux.vnet.ibm.com>
	<20100826201906.GD19906@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	ying.lok@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752338Ab0HZVJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 17:09:52 -0400
In-Reply-To: <20100826201906.GD19906@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 26 Aug 2010 13:19:06 -0700

> Breno,
> looks good.
> Thanks

Please do not top-post.

> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
...
> On Thu, Aug 26, 2010 at 11:27:58AM -0700, leitao@linux.vnet.ibm.com wrote:
>> Qlge is freeing the buffers before stopping the card DMA, and
>> this can cause some severe error, as a EEH event on PPC.
>> 
>> This patch just stop the card and then free the resources.
>> 
>> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks.
