From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix INTx fallback when MSI fails
Date: Wed, 21 Apr 2010 16:17:51 -0700 (PDT)
Message-ID: <20100421.161751.94080129.davem@davemloft.net>
References: <201004161015.12089.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: adetsch@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50435
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754784Ab0DUXRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:17:47 -0400
In-Reply-To: <201004161015.12089.adetsch@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andre Detsch <adetsch@br.ibm.com>
Date: Fri, 16 Apr 2010 10:15:11 -0300

> tg3: Fix INTx fallback when MSI fails
> 
> MSI setup changes the value of some key attributes of struct tg3 *tp.
> These attributes must be taken into account and restored before
> we try to do a new request_irq for INTx fallback.
> 
> In powerpc, the original code was leading to an EINVAL return within
> request_irq, because the driver was trying to use the disabled MSI
> virtual irq number instead of tp->pdev->irq.
> 
> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

Broadcom folks, please review, thanks.
