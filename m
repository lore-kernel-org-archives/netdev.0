From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: Only free resources if they were allocated
Date: Mon, 25 Jan 2010 15:47:07 -0800 (PST)
Message-ID: <20100125.154707.32746579.davem@davemloft.net>
References: <1264436252-3740-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751112Ab0AYXqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 18:46:55 -0500
In-Reply-To: <1264436252-3740-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Mon, 25 Jan 2010 10:17:32 -0600

> Currently qlge tries to release regions even if they were not allocated.
> This causes messages like the following in the kernel log
> 
> Trying to free nonexistent resource <00000000006af400-00000000006af4ff>
> Trying to free nonexistent resource <00003c04ff9f4000-00003c04ff9f7fff>
> Trying to free nonexistent resource <00003c04ffc00000-00003c04ffcfffff>
> 
> This patch fixes the goto logic in order to not release the resources
> if they were not allocated.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks a lot.
