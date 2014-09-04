From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: cpsw: improve interrupt lookup logic in
 cpsw_probe()
Date: Thu, 4 Sep 2014 19:36:18 +0530
Message-ID: <540871DA.7090608@ti.com>
References: <1409814023-10189-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <netdev@vger.kernel.org>,
	<george.cherian@ti.com>, Daniel Mack <zonque@gmail.com>
To: Daniel Mack <daniel@zonque.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:35009 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbaIDOG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:06:29 -0400
In-Reply-To: <1409814023-10189-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 September 2014 12:30 PM, Daniel Mack wrote:
> From: Daniel Mack <zonque@gmail.com>
> 
> Simplify the interrupt resource lookup code in cpsw_probe() by the
> following:
> 
>  * Only look at the first member of the resource. As the driver only
>    works for DT-enabled platforms anyway, a resource of type
>    IORESOURCE_IRQ will only contain one single entry
>    (res->start == res->end), so there is no need for the iteration.
> 
>  * Add a bounds check to avoid overflows if we are passed more than
>    ARRAY_SIZE(priv->irqs_table) resources.
> 
>  * Assign 'ret' with the return value of devm_request_irq() so that
>    cpsw_probe() returns the appropriate error code.
> 
>  * If devm_request_irq() fails, report the error code in the log
>    message.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Acked-by: Mugunthan V N <mugunthanvnm@gmail.com>

Regards
Mugunthan V N
