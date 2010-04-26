From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tg3: Fix INTx fallback when MSI fails
Date: Mon, 26 Apr 2010 11:10:17 -0700 (PDT)
Message-ID: <20100426.111017.189698604.davem@davemloft.net>
References: <201004161015.12089.adetsch@br.ibm.com>
	<20100421.161751.94080129.davem@davemloft.net>
	<201004261427.07099.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: adetsch@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54390
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751521Ab0DZSKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:10:11 -0400
In-Reply-To: <201004261427.07099.adetsch@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andre Detsch <adetsch@br.ibm.com>
Date: Mon, 26 Apr 2010 14:27:07 -0300

> tg3: Fix INTx fallback when MSI fails
> 
> MSI setup changes the value of irq_vec in struct tg3 *tp.
> This attribute must be taken into account and restored before
> we try to do a new request_irq for INTx fallback.
> 
> In powerpc, the original code was leading to an EINVAL return within
> request_irq, because the driver was trying to use the disabled MSI
> virtual irq number instead of tp->pdev->irq.
> 
> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

Broadcom folks, I've already asked you to review Andre's original patch.

If you can't be bothered to look at and ACK/NACK a simple fix like
this for 10 days, then I'm just going to apply Andre's patch as-is
since it looks right to me.

If the idea was to bundle this up into a set of 15 patches you guys
already have ready to bomb at me, I absolutely do not want you guys to
operate that way.  It doesn't work.  You should be able to ACK a
simple patch like this as soon as possible so it can be integrated
upstream in the most expediant manner possible.

Thanks.
